import 'package:flutter/material.dart';
import 'package:manager/core/services/logs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeChangeNotifier with ChangeNotifier {
  /// [_isDarkTheme] boolean value that indicates
  /// whether the app is currently in DarkTheme mode.
  bool _isDarkTheme = false;
  ThemeChangeNotifier() {
    loadSharedPref();
  }

  Future<void> loadSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('DARK_THEME')) {
      darkTheme = prefs.getBool('DARK_THEME')!;
    } else {
      darkTheme = false;
    }
  }

  /// DarkTheme getter
  bool get isDarkTheme => _isDarkTheme;

  /// DarkTheme setter
  set darkTheme(bool value) {
    _isDarkTheme = value;
    notifyListeners();
    logger.file(LogTypeTag.INFO, 'Dark theme setter set to $value.');
  }

  Future<void> updateTheme(bool isDarkTheme) async {
    _isDarkTheme = isDarkTheme;
    notifyListeners();
    await logger.file(LogTypeTag.INFO, 'Dark theme updated to $isDarkTheme.');
    await SharedPref().prefs.setBool('DARK_THEME', isDarkTheme);
  }
}

class SharedPref {
  SharedPref._();
  factory SharedPref() => _instance;
  static final SharedPref _instance = SharedPref._();
  late final SharedPreferences _prefs;
  SharedPreferences get prefs => _prefs;
  static Future<void> init() async {
    _instance._prefs = await SharedPreferences.getInstance();
  }
}
