import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/navigation/floating_nav_bar.dart';
import '../../../admin/presentation/pages/admin_companies_page.dart';
import '../../../admin/presentation/pages/admin_profile_page.dart';
import '../../../admin/presentation/pages/admin_users_page.dart';
import '../../../analytics/presentation/pages/employer_analytics_page.dart';
import '../../../applications/presentation/pages/applications_overview_page.dart';
import '../../../applications/presentation/pages/my_applications_page.dart';
import '../../../candidate_profile/presentation/pages/candidate_profile_page.dart';
import '../../../chat/presentation/pages/chat_threads_page.dart';
import '../../../company_profile/presentation/pages/company_profile_page.dart';
import '../../../vacancies/presentation/pages/my_vacancies_page.dart';
import '../../../vacancies/presentation/pages/saved_vacancies_page.dart';
import '../../../vacancies/presentation/pages/vacancies_list_page.dart';

class HomePage extends StatefulWidget {
  final String role;

  const HomePage({super.key, required this.role});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  late final List<FloatingNavItem> _navItems = _buildNavItems();
  late final List<Widget> _pages = _buildPages();

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
                onTap: (index) => setState(() => _currentIndex = index),
                items: _navItems,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
