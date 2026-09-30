import 'package:go_router/go_router.dart';
import 'package:jobway_app/core/network/dio_client.dart';
import 'package:jobway_app/core/router/app_routes.dart';
import 'package:jobway_app/features/applications/presentation/pages/vacancy_applications_page.dart';
import 'package:jobway_app/features/auth/presentation/pages/auth_gate.dart';
import 'package:jobway_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:jobway_app/features/auth/presentation/pages/login_page.dart';
import 'package:jobway_app/features/auth/presentation/pages/register_page.dart';
import 'package:jobway_app/features/auth/presentation/pages/reset_password_page.dart';
import 'package:jobway_app/features/auth/presentation/pages/verify_reset_code_page.dart';
import 'package:jobway_app/features/candidate_profile/domain/entities/candidate_profile.dart';
import 'package:jobway_app/features/candidate_profile/presentation/pages/candidate_profile_view_page.dart';
import 'package:jobway_app/features/candidate_profile/presentation/pages/edit_candidate_profile_page.dart';
import 'package:jobway_app/features/chat/presentation/pages/chat_page.dart';
import 'package:jobway_app/features/chat/presentation/pages/chat_threads_page.dart';
import 'package:jobway_app/features/company_profile/domain/entities/company_profile.dart';
import 'package:jobway_app/features/company_profile/presentation/pages/edit_company_profile_page.dart';
import 'package:jobway_app/features/home/presentation/pages/home_page.dart';
import 'package:jobway_app/features/notifications/presentation/pages/notifications_page.dart';
import 'package:jobway_app/features/review/presentation/pages/all_reviews_page.dart';
import 'package:jobway_app/features/settings/presentation/pages/change_password_page.dart';
import 'package:jobway_app/features/settings/presentation/pages/settings_page.dart';
import 'package:jobway_app/features/vacancies/domain/entities/vacancy.dart';
import 'package:jobway_app/features/vacancies/presentation/pages/create_vacancy_page.dart';
import 'package:jobway_app/features/vacancies/presentation/pages/edit_vacancy_page.dart';
import 'package:jobway_app/features/vacancies/presentation/pages/vacancy_detail_page.dart';

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const AuthGate()),
    GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginPage()),
    GoRoute(path: AppRoutes.register, builder: (_, __) => const RegisterPage()),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (_, __) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: AppRoutes.verifyResetCode,
      builder: (_, state) => VerifyResetCodePage(email: state.extra as String),
    ),
    GoRoute(
      path: AppRoutes.resetPassword,
      builder: (_, state) => ResetPasswordPage(email: state.extra as String),
    ),
    GoRoute(
      path: '/home/:role',
      builder: (_, state) => HomePage(role: state.pathParameters['role']!),
    ),
    GoRoute(
      path: '/vacancy/:id',
      builder: (_, state) =>
          VacancyDetailPage(vacancyId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/vacancy/:id/applications',
      builder: (_, state) {
        final args = state.extra as VacancyApplicationsArgs;
        return VacancyApplicationsPage(
          vacancyId: state.pathParameters['id']!,
          vacancyTitle: args.title,
          vacancyStatus: args.status,
        );
      },
    ),
    GoRoute(
      path: '/candidate/:id',
      builder: (_, state) => CandidateProfileViewPage(
        candidateProfileId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      builder: (_, __) => const NotificationsPage(),
    ),
    GoRoute(
      path: '/reviews/:userId',
      builder: (_, state) =>
          AllReviewsPage(userId: state.pathParameters['userId']!),
    ),
    GoRoute(
      path: AppRoutes.createVacancy,
      builder: (_, __) => const CreateVacancyPage(),
    ),
    GoRoute(
      path: AppRoutes.editCandidateProfile,
      builder: (_, state) =>
          EditCandidateProfilePage(profile: state.extra as CandidateProfile),
    ),
    GoRoute(
      path: AppRoutes.editCompanyProfile,
      builder: (_, state) =>
          EditCompanyProfilePage(profile: state.extra as CompanyProfile),
    ),
    GoRoute(path: AppRoutes.settings, builder: (_, __) => const SettingsPage()),
    GoRoute(
      path: AppRoutes.changePassword,
      builder: (_, __) => const ChangePasswordPage(),
    ),
    GoRoute(
      path: AppRoutes.editVacancy,
      builder: (_, state) => EditVacancyPage(vacancy: state.extra as Vacancy),
    ),
    GoRoute(path: AppRoutes.chats, builder: (_, __) => const ChatThreadsPage()),
    GoRoute(
      path: '/chat/:id',
      builder: (_, state) {
        final args = state.extra as ChatArgs;
        return ChatPage(
          jobApplicationId: state.pathParameters['id']!,
          otherUserId: args.otherUserId,
          otherUserName: args.otherUserName,
          otherUserPhotoUrl: args.otherUserPhotoUrl,
          otherUserActive: args.otherUserActive,
          vacancyTitle: args.vacancyTitle,
        );
      },
    ),
  ],
);
