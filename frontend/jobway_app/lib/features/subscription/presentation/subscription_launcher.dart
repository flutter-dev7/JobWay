import '../../../core/utils/contact_launcher.dart';

class SubscriptionLauncher {
  static Future<void> openTelegram(String username, String message) =>
      ContactLauncher.openTelegram(username, message);

  static Future<void> callPhone(String phone) => ContactLauncher.callPhone(phone);
}