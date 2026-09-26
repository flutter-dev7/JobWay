import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/vacancies/presentation/pages/vacancy_detail_page.dart';
import '../../features/candidate_profile/presentation/pages/candidate_profile_view_page.dart';
// ... остальные импорты

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),
    GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordPage()),
    GoRoute(
      path: '/vacancy/:id',
      builder: (context, state) => VacancyDetailPage(vacancyId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/candidate/:id',
      builder: (context, state) => CandidateProfileViewPage(candidateProfileId: state.pathParameters['id']!),
    ),
    // ...
  ],
);