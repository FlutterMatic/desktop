import 'package:flutter/material.dart';
import 'package:flutter_installer/utils/constants.dart';

CustomTheme currentTheme = CustomTheme();

class CustomTheme with ChangeNotifier {
  static bool _isDarkTheme = false;
  ThemeMode get currentTheme => _isDarkTheme ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
  }

  static ThemeData get lightTheme => ThemeData(
        primaryColor: Colors.lightBlue,
        accentColor: Colors.white,
        backgroundColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        primaryColorLight: kGreyColor,
        iconTheme: const IconThemeData(color: Colors.black),
        textTheme: const TextTheme(
          headline1: TextStyle(color: Colors.black),
          headline2: TextStyle(color: Colors.black),
          bodyText1: TextStyle(color: Colors.black),
          bodyText2: TextStyle(color: Colors.black),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        primaryColor: Colors.black,
        dividerColor: Colors.white,
        accentColor: const Color(0xFF4183E3),
        primaryColorLight: const Color(0xFF373E47),
        focusColor: const Color(0xFF444C56),
        backgroundColor: const Color(0xFF22272E),
        scaffoldBackgroundColor: const Color(0xFF22272E),
        iconTheme: const IconThemeData(color: Colors.white),
        textTheme: const TextTheme(
          headline1: TextStyle(
            color: Colors.white,
          ),
          headline2: TextStyle(
            color: Colors.white,
          ),
          bodyText1: TextStyle(
            color: Colors.white,
          ),
          bodyText2: TextStyle(
            color: Colors.white,
          ),
        ),
      );
}
