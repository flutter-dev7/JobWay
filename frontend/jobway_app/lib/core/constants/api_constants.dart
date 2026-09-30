class ApiConstants {
  static const String baseUrl = 'http://192.168.123.34:5025/api';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyResetCode = '/auth/verify-reset-code';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String refreshToken = '/auth/refresh-token';
  static const String sendRegistrationCode = '/auth/send-registration-code';
  static const String verifyRegistrationCode = '/auth/verify-registration-code';
  static const String deleteAccount = '/auth/delete-account';

  // Skills
  static const String skills = '/skills';

  // Profiles
  static const String candidateProfileMe = '/candidate-profile/me';
  static String candidateProfileById(String id) => '/candidate-profile/$id';
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

  // Reviews
  static const String reviewCreate = '/review/create';
  static String reviewsForUser(String userId) => '/review/user/$userId';
  static String reviewAverageRating(String userId) =>
      '/review/user/$userId/average-rating';

  // Chat
  static const String chatThreads = '/chat/threads';
  static String chatMessages(String jobApplicationId) =>
      '/chat/$jobApplicationId/messages';

  // Analytics
  static const String employerAnalytics = '/analytics/employer';

  static const String uploadResume = '/candidate-profile/me/resume';

  static const String registerDeviceToken = '/notifications/device-token';

  static const String uploadCandidatePhoto = '/candidate-profile/me/photo';
  static const String uploadCompanyLogo = '/company-profile/me/logo';

  static String get fileBaseUrl {
    final uri = Uri.parse(baseUrl);
    return '${uri.scheme}://${uri.authority}';
  }
}
