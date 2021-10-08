// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// 🌎 Project imports:
import 'package:manager/core/services/logs.dart';
import 'package:manager/meta/utils/shared_pref.dart';

class ThemeChangeNotifier with ChangeNotifier {
  /// [_isDarkTheme] boolean value that indicates
  /// whether the app is currently in DarkTheme mode.
  bool _isDarkTheme = true;
  ThemeChangeNotifier() {
    loadSharedPref();
  }

  Future<void> loadSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('DARK_THEME')) {
      darkTheme = prefs.getBool('DARK_THEME')!;
    } else {
      darkTheme = true;
      await prefs.setBool('DARK_THEME', true);
    }
  }

  /// DarkTheme getter
  bool get isDarkTheme => _isDarkTheme;

  /// DarkTheme setter
  set darkTheme(bool value) {
    _isDarkTheme = value;
    notifyListeners();
    logger.file(LogTypeTag.info, 'Dark theme setter set to $value.');
  }

  Future<void> updateTheme(bool isDarkTheme) async {
    _isDarkTheme = isDarkTheme;
    notifyListeners();
    await logger.file(LogTypeTag.info, 'Dark theme updated to $isDarkTheme.');
    await SharedPref().pref.setBool('DARK_THEME', isDarkTheme);
  }
}
