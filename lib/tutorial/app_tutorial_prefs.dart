import 'package:shared_preferences/shared_preferences.dart';

abstract final class AppTutorialPrefs {
  static const _hasSeenTutorialKey = 'has_seen_product_tutorial';

  static Future<bool> hasSeenTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenTutorialKey) ?? false;
  }

  static Future<void> markTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenTutorialKey, true);
  }
}
