class ApiConstants {
  static const String baseUrl = 'http://192.168.1.5:5025/api';

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
  static const String health = '/health';

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
  static const String savedVacancyIds = '$savedVacancies/ids';
  static const String savedVacancies = '/vacancies/saved';
  static const String vacanciesTodayCount = '/vacancies/today-count';
  static String promoteVacancy(String id) => '/vacancies/$id/promote';

  // Applications
  static String applyToVacancy(String vacancyId) =>
      '/vacancies/$vacancyId/applications';
  static String vacancyApplications(String vacancyId) =>
      '/vacancies/$vacancyId/applications';
  static const String myApplications = '/applications/my';
  static String applicationStatus(String applicationId) =>
      '/applications/$applicationId/status';
  static const String myAppliedVacancyIds = '$myApplications/vacancy-ids';

  static const String mySubscription = '/subscription/my';
  static String setCompanyTier(String id) => '/admin/companies/$id/tier';

  // Notifications
  static const String myNotifications = '/notifications/my';
  static const String unreadNotificationsCount = '/notifications/unread-count';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const String markAllNotificationsRead = '/notifications/read-all';

  // Admin
  static const String adminCompanies = '/admin/companies';
  static String verifyCompany(String id) => '/admin/companies/$id/verify';
  static String rejectCompany(String id) => '/admin/companies/$id/reject';
  static const String adminUsers = '/admin/users';
  static String blockUser(String id) => '/admin/users/$id/block';
  static String unblockUser(String id) => '/admin/users/$id/unblock';
  static String adminCompanyVacancies(String id) =>
      '/admin/companies/$id/vacancies';
  static String featureVacancy(String id) => '/admin/vacancies/$id/feature';
  static String adminCompanyById(String id) => '/admin/companies/$id';

  // Reviews
  static const String reviewCreate = '/review/create';
  static String reviewsForUser(String userId) => '/review/user/$userId';
  static String reviewAverageRating(String userId) =>
      '/review/user/$userId/average-rating';

  // Chat
  static const String chatThreads = '/chat/threads';
  static String chatMessages(String jobApplicationId) =>
      '/chat/$jobApplicationId/messages';

  // Search
  static const String searchCompanies = '/search/companies';
  static const String searchCandidates = '/search/candidates';
  static String publicCompany(String id) => '/companies/$id';
  static String publicCompanyVacancies(String id) => '/companies/$id/vacancies';
  static const String candidateVisibility = '/candidate-profile/me/visibility';

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

  static String get serverUrl => baseUrl.replaceFirst(RegExp(r'/api/?$'), '');

  static String resolveFileUrl(String url) {
    if (url.startsWith('/')) return '$serverUrl$url';

    final uri = Uri.tryParse(url);
    if (uri != null &&
        uri.path.startsWith('/uploads/') &&
        _isLocalHost(uri.host)) {
      return '$serverUrl${uri.path}';
    }

    return url;
  }

  static bool _isLocalHost(String host) =>
      host == 'localhost' ||
      host.startsWith('192.168.') ||
      host.startsWith('10.') ||
      host.startsWith('172.');

  static String extractFileName(String url) {
    final withoutQuery = url.split('?').first;
    final fileName = withoutQuery.split('/').last;
    final parts = fileName.split('_');
    if (parts.length >= 3) {
      return 'Резюме${_extensionOf(fileName)}';
    }
    return fileName;
  }

  static String _extensionOf(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    return dotIndex >= 0 ? fileName.substring(dotIndex) : '';
  }
}
