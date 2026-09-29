class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const verifyResetCode = '/verify-reset-code';
  static const resetPassword = '/reset-password';
  static const notifications = '/notifications';
  static const createVacancy = '/create-vacancy';
  static const editCandidateProfile = '/edit-candidate-profile';
  static const editCompanyProfile = '/edit-company-profile';
  static const settings = '/settings';
  static const changePassword = '/change-password';
  static const editVacancy = '/edit-vacancy';

  static String home(String role) => '/home/$role';
  static String vacancy(String id) => '/vacancy/$id';
  static String vacancyApplications(String id) => '/vacancy/$id/applications';
  static String candidate(String id) => '/candidate/$id';
  static String reviews(String userId) => '/reviews/$userId';
}

class VacancyApplicationsArgs {
  final String title;
  final String status;

  const VacancyApplicationsArgs({required this.title, required this.status});
}
