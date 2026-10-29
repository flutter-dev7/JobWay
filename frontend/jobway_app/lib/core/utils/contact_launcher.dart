import 'package:url_launcher/url_launcher.dart';
import '../widgets/feedback/app_snackbar.dart';

class ContactLauncher {
  // Сначала открываем приложение Telegram, если его нет, то ссылку в браузере
  static Future<void> openTelegram(String username, String message) async {
    final text = Uri.encodeComponent(message);
    final appUri = Uri.parse('tg://resolve?domain=$username&text=$text');
    final webUri = Uri.parse('https://t.me/$username?text=$text');

    try {
      final opened = await launchUrl(appUri, mode: LaunchMode.externalApplication);
      if (opened) return;
    } catch (_) {
      // приложения нет, пробуем браузер
    }

    try {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      AppSnackbar.showError('Не удалось открыть Telegram');
    }
  }

  static Future<void> callPhone(String phone) async {
    try {
      await launchUrl(Uri.parse('tel:$phone'));
    } catch (_) {
      AppSnackbar.showError('Не удалось открыть набор номера');
    }
  }
}