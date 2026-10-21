import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/features/admin/domain/entities/user_moderation.dart';
import 'package:jobway_app/features/admin/presentation/pages/admin_company_loader_page.dart';
import 'package:jobway_app/features/candidate_profile/presentation/pages/candidate_profile_view_page.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/feedback/empty_state.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_filter_chips.dart';
import '../widgets/admin_search_field.dart';
import '../widgets/user_moderation_card.dart';

class AdminUsersPage extends ConsumerStatefulWidget {
  const AdminUsersPage({super.key});

  @override
  ConsumerState<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends ConsumerState<AdminUsersPage> {
  final _scrollController = ScrollController();

  static const _labels = [
    'Все',
    'Кандидаты',
    'Работодатели',
    'Заблокированные',
  ];
  static const List<({String? role, bool? isActive})> _filters = [
    (role: null, isActive: null),
    (role: 'Candidate', isActive: null),
    (role: 'Employer', isActive: null),
    (role: null, isActive: false),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  AdminUsersController get _controller =>
      ref.read(adminUsersControllerProvider.notifier);

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      _controller.loadMore();
    }
  }

  void _openProfile(UserModeration user) {
    final profileId = user.profileId;

    if (profileId == null) {
      AppSnackbar.showError(
        user.role == 'Admin'
            ? 'У администратора нет профиля'
            : 'Профиль пользователя не найден',
      );
      return;
    }

    final Widget? page = switch (user.role) {
      'Candidate' => CandidateProfileViewPage(candidateProfileId: profileId),
      'Employer' => AdminCompanyLoaderPage(companyId: profileId),
      _ => null,
    };
    if (page == null) return;

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Widget _buildBody(AdminUsersState state) {
    if (state.isLoading && state.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.users.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 120),
          Text(state.error!, textAlign: TextAlign.center),
        ],
      );
    }

    if (state.users.isEmpty) {
      return const EmptyState(
        icon: Icons.people_outline_rounded,
        title: 'Пользователей нет',
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      itemCount: state.users.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.users.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final user = state.users[index];
        return UserModerationCard(
          key: ValueKey(user.id),
          user: user,
          isUpdating: state.updatingId == user.id,
          onTap: () => _openProfile(user),
          onToggle: () async {
            try {
              await _controller.toggle(user);
              AppSnackbar.showSuccess(
                user.isActive
                    ? 'Пользователь заблокирован'
                    : 'Пользователь разблокирован',
              );
            } catch (error) {
              AppSnackbar.showError(ApiException.extractMessage(error));
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminUsersControllerProvider);
    final colors = context.colors;

    final selectedIndex = _filters.indexWhere(
      (f) => f.role == state.role && f.isActive == state.isActive,
    );

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Пользователи',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: AdminSearchField(
              hint: 'Поиск по email',
              onChanged: _controller.applySearch,
            ),
          ),
          AdminFilterChips(
            labels: _labels,
            selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
            onSelected: (index) => _controller.applyFilter(
              role: _filters[index].role,
              isActive: _filters[index].isActive,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Найдено: ${state.totalCount}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _controller.load,
              child: _buildBody(state),
            ),
          ),
        ],
      ),
    );
  }
}
