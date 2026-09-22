class ApiConstants {
  static const String baseUrl = 'http://192.168.123.37:5025/api';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyResetCode = '/auth/verify-reset-code';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String refreshToken = '/auth/refresh-token';

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
  static String saveVacancy(String id) => '/vacancies/$id/save';
  static const String savedVacancies = '/vacancies/saved';
  static const String vacanciesTodayCount = '/vacancies/today-count';

  // Applications
  static String applyToVacancy(String vacancyId) =>
      '/vacancies/$vacancyId/applications';
  static String vacancyApplications(String vacancyId) =>
      '/vacancies/$vacancyId/applications';
  static const String myApplications = '/applications/my';
  static String applicationStatus(String applicationId) =>
      '/applications/$applicationId/status';

  // Notifications
  static const String myNotifications = '/notifications/my';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const String markAllNotificationsRead = '/notifications/read-all';

  // Admin
  static const String adminCompanies = '/admin/companies';
  static String verifyCompany(String id) => '/admin/companies/$id/verify';
  static String rejectCompany(String id) => '/admin/companies/$id/reject';
  static const String adminUsers = '/admin/users';
  static String blockUser(String id) => '/admin/users/$id/block';
  static String unblockUser(String id) => '/admin/users/$id/unblock';
}
