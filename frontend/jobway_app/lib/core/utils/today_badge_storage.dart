import 'package:shared_preferences/shared_preferences.dart';

class TodayBadgeStorage {
  static const _key = 'today_badge_dismissed_date';

  static Future<bool> wasDismissedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    final today = DateTime.now().toIso8601String().split('T').first;
    return saved == today;
  }

  static Future<void> dismissForToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T').first;
    await prefs.setString(_key, today);
  }
}