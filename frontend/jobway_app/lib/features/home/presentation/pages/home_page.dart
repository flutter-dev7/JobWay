import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/core/providers/navigation_providers.dart';
import 'package:jobway_app/core/services/local_notification_service.dart';
import 'package:jobway_app/core/theme/app_theme_extension.dart';
import 'package:jobway_app/core/widgets/navigation/floating_nav_bar.dart';
import 'package:jobway_app/features/admin/presentation/pages/admin_companies_page.dart';
import 'package:jobway_app/features/admin/presentation/pages/admin_profile_page.dart';
import 'package:jobway_app/features/admin/presentation/pages/admin_users_page.dart';
import 'package:jobway_app/features/admin/presentation/providers/admin_provider.dart';
import 'package:jobway_app/features/analytics/presentation/pages/employer_analytics_page.dart';
import 'package:jobway_app/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:jobway_app/features/applications/presentation/pages/applications_overview_page.dart';
import 'package:jobway_app/features/applications/presentation/pages/my_applications_page.dart';
import 'package:jobway_app/features/applications/presentation/providers/applications_provider.dart';
import 'package:jobway_app/features/candidate_profile/presentation/pages/candidate_profile_page.dart';
import 'package:jobway_app/features/candidate_profile/presentation/providers/candidate_profile_provider.dart';
import 'package:jobway_app/features/chat/presentation/pages/chat_threads_page.dart';
import 'package:jobway_app/features/chat/presentation/providers/chat_threads_controller.dart';
import 'package:jobway_app/features/company_profile/presentation/pages/company_profile_page.dart';
import 'package:jobway_app/features/company_profile/presentation/providers/company_profile_provider.dart';
import 'package:jobway_app/features/invitations/presentation/providers/invitations_provider.dart';
import 'package:jobway_app/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:jobway_app/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:jobway_app/features/vacancies/presentation/pages/my_vacancies_page.dart';
import 'package:jobway_app/features/vacancies/presentation/pages/saved_vacancies_page.dart';
import 'package:jobway_app/features/vacancies/presentation/pages/vacancies_list_page.dart';
import 'package:jobway_app/features/vacancies/presentation/providers/my_vacancies_controller.dart';
import 'package:jobway_app/features/vacancies/presentation/providers/saved_vacancies_controller.dart';
import 'package:jobway_app/features/vacancies/presentation/providers/vacancies_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomePage extends ConsumerStatefulWidget {
  final String role;

  const HomePage({super.key, required this.role});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  // Не обновляем одну вкладку чаще этого интервала
  static const _refreshInterval = Duration(seconds: 20);

  int _currentIndex = 0;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  final _lastRefresh = <int, DateTime>{0: DateTime.now()};

  late final List<FloatingNavItem> _navItems = _buildNavItems();
  late final List<Widget> _pages = _buildPages();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _messageSubscription = FirebaseMessaging.onMessage.listen(
      _onForegroundMessage,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshTab(_currentIndex, force: true);
    }
  }

  // Push пришёл при открытом приложении: показываем баннер и обновляем данные
  Future<void> _onForegroundMessage(RemoteMessage message) async {
    await LocalNotificationService.showFromMessage(message);
    if (!mounted) return;

    _refreshTab(_currentIndex, force: true);

    if (widget.role != 'Admin' && _currentIndex != 2) {
      ref.read(chatThreadsControllerProvider.notifier).load();
    }
    if (widget.role == 'Employer' && _currentIndex != 0) {
      ref.read(myVacanciesControllerProvider.notifier).load();
      ref.invalidate(subscriptionProvider);
    }
  }

  void _refreshTab(int index, {bool force = false}) {
    final last = _lastRefresh[index];
    if (!force &&
        last != null &&
        DateTime.now().difference(last) < _refreshInterval) {
      return;
    }
    _lastRefresh[index] = DateTime.now();

    ref.invalidate(unreadNotificationsCountProvider);

    switch (widget.role) {
      case 'Employer':
        switch (index) {
          case 0:
            ref.read(myVacanciesControllerProvider.notifier).load();
            ref.invalidate(subscriptionProvider);
          case 1:
            ref.read(applicationsOverviewControllerProvider.notifier).load();
          case 2:
            ref.read(chatThreadsControllerProvider.notifier).load();
          case 3:
            ref.invalidate(employerAnalyticsProvider);
            ref.invalidate(pendingInvitationsProvider);
          case 4:
            ref.invalidate(companyProfileProvider);
            ref.invalidate(subscriptionProvider);
        }
      case 'Admin':
        switch (index) {
          case 0:
            ref.read(adminCompaniesControllerProvider.notifier).load();
          case 1:
            ref.read(adminUsersControllerProvider.notifier).load();
        }
      default:
        switch (index) {
          case 0:
            ref.read(vacanciesControllerProvider.notifier).load();
          case 1:
            ref.read(savedVacanciesControllerProvider.notifier).load();
          case 2:
            ref.read(chatThreadsControllerProvider.notifier).load();
          case 3:
            ref.read(myApplicationsControllerProvider.notifier).load();
            ref.invalidate(myAppliedVacancyIdsProvider);
          case 4:
            ref.invalidate(candidateProfileProvider);
        }
    }
  }

  List<FloatingNavItem> _buildNavItems() {
    switch (widget.role) {
      case 'Employer':
        return [
          FloatingNavItem(icon: LucideIcons.briefcase, label: 'Вакансии'),
          FloatingNavItem(icon: LucideIcons.users, label: 'Отклики'),
          FloatingNavItem(icon: LucideIcons.send, label: 'Чаты'),
          FloatingNavItem(icon: LucideIcons.barChart3, label: 'Аналитика'),
          FloatingNavItem(icon: LucideIcons.building2, label: 'Компания'),
        ];
      case 'Admin':
        return [
          FloatingNavItem(icon: LucideIcons.building2, label: 'Компании'),
          FloatingNavItem(icon: LucideIcons.users, label: 'Юзеры'),
          FloatingNavItem(icon: LucideIcons.user, label: 'Профиль'),
        ];
      default:
        return [
          FloatingNavItem(icon: LucideIcons.search, label: 'Вакансии'),
          FloatingNavItem(icon: LucideIcons.bookmark, label: 'Сохранённые'),
          FloatingNavItem(icon: LucideIcons.send, label: 'Чаты'),
          FloatingNavItem(icon: LucideIcons.clipboardList, label: 'Отклики'),
          FloatingNavItem(icon: LucideIcons.user, label: 'Профиль'),
        ];
    }
  }

  List<Widget> _buildPages() {
    switch (widget.role) {
      case 'Employer':
        return const [
          MyVacanciesPage(),
          ApplicationsOverviewPage(),
          ChatThreadsPage(),
          EmployerAnalyticsPage(),
          CompanyProfilePage(),
        ];
      case 'Admin':
        return const [
          AdminCompaniesPage(),
          AdminUsersPage(),
          AdminProfilePage(),
        ];
      default:
        return const [
          VacanciesListPage(),
          SavedVacanciesPage(),
          ChatThreadsPage(),
          MyApplicationsPage(),
          CandidateProfilePage(),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int?>(homeTabRequestProvider, (_, index) {
      if (index == null) return;
      ref.read(homeTabRequestProvider.notifier).state = null;
      if (widget.role == 'Admin' || index >= _pages.length) return;
      setState(() => _currentIndex = index);
      _refreshTab(index, force: true);
    });

    ref.listen<AsyncValue<int>>(unreadNotificationsCountProvider, (
      previous,
      next,
    ) {
      final before = previous?.valueOrNull;
      final after = next.valueOrNull;
      if (before == null || after == null || after <= before) return;

      // Пришло новое уведомление: данные на экранах могли измениться на сервере
      _refreshTab(_currentIndex, force: true);
      if (widget.role == 'Employer') {
        ref.read(myVacanciesControllerProvider.notifier).load();
        ref.invalidate(subscriptionProvider);
      }
    });

    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _pages),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomInset + 16,
            child: Center(
              child: FloatingNavBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() => _currentIndex = index);
                  _refreshTab(index);
                },
                items: _navItems,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
