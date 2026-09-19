class ApiConstants {
  static const String baseUrl = 'http://192.168.123.33:5025/api';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyResetCode = '/auth/verify-reset-code';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';

  // Skills
  static const String skills = '/skills';

  // Profiles
  static const String candidateProfileMe = '/candidate-profile/me';
  static const String companyProfileMe = '/company-profile/me';

  // Vacancies
  static const String vacancies = '/vacancies';
  static String vacancyById(String id) => '/vacancies/$id';
  static String publishVacancy(String id) => '/vacancies/$id/publish';
  static String closeVacancy(String id) => '/vacancies/$id/close';
  static const String myVacancies = '/vacancies/my';

  // Applications
  static String applyToVacancy(String vacancyId) => '/vacancies/$vacancyId/applications';
  static String vacancyApplications(String vacancyId) => '/vacancies/$vacancyId/applications';
  static const String myApplications = '/applications/my';
  static String applicationStatus(String applicationId) => '/applications/$applicationId/status';

  // Notifications
  static const String myNotifications = '/notifications/my';
  static String markNotificationRead(String id) => '/notifications/$id/read';
}