import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();
  static final Color darkBackgroundColor = const Color(0xFF181C1E);
  static final Color darkCardColor = const Color(0xFF262F34);
  static final Color darkLightColor = const Color(0xFF656D77);
  static final Color lightBackgroundColor = const Color(0xFFFFFFFF);
  static final Color lightComponentsColor = const Color(0xFF40CAFF);
  static final Color lightCardColor = const Color(0xFFF4F8FA);
  static final Color primaryColor = const Color(0xFF206BC4);
  static const Color errorColor = Color(0xFFD73A49);
  static ThemeData get lightTheme => ThemeData(
        fontFamily: 'NotoSans',
        brightness: Brightness.light,
        primaryColor: lightBackgroundColor,
        backgroundColor: lightBackgroundColor,
        scaffoldBackgroundColor: lightBackgroundColor,
        buttonColor: primaryColor,
        accentColor: const Color(0xFF79A6DC),
        primaryColorLight: const Color(0xFFF1F1F1),
        splashColor: Colors.transparent,
        errorColor: errorColor,
        highlightColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
        textTheme: const TextTheme(
          headline1: TextStyle(color: Colors.black),
          headline2: TextStyle(color: Colors.black),
          bodyText1: TextStyle(color: Colors.black),
          bodyText2: TextStyle(color: Colors.black),
        ),
      );
  static ThemeData get darkTheme => ThemeData(
        fontFamily: 'NotoSans',
        primaryColor: darkBackgroundColor,
        brightness: Brightness.dark,
        backgroundColor: darkBackgroundColor,
        unselectedWidgetColor: Colors.blueGrey.withOpacity(0.4),
        scaffoldBackgroundColor: darkBackgroundColor,
        primaryColorLight: const Color(0xFF2D333A),
        buttonColor: const Color(0xFF373E47),
        focusColor: const Color(0xFF444C56),
        accentColor: const Color(0xFF6E7681),
        errorColor: errorColor,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        dividerColor: Colors.white,
        textTheme: const TextTheme(
          headline1: TextStyle(color: Color(0xffCDD4DD)),
          headline2: TextStyle(color: Color(0xffCDD4DD)),
          bodyText1: TextStyle(color: Color(0xffCDD4DD)),
          bodyText2: TextStyle(color: Color(0xffCDD4DD)),
        ),
      );
}

extension MyThemeData on ThemeData {
  bool get isDarkTheme => brightness == Brightness.dark;
  bool get isLightTheme => brightness == Brightness.light;
}
