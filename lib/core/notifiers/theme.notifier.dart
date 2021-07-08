import 'package:flutter/material.dart';
import 'package:manager/core/services/logs.dart';

class ThemeChangeNotifier with ChangeNotifier {
  bool _isDarkTheme = false;
  bool get isDarkTheme => _isDarkTheme;
  Future<void> updateTheme(bool isDarkTheme) async {
    _isDarkTheme = isDarkTheme;
    await logger.file(LogTypeTag.INFO, 'Changing the theme.');
    notifyListeners();
  }
}
