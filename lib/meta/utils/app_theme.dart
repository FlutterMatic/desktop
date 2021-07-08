import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();
  static final Color darkBackgroundColor = const Color(0xFF121212);
  static final Color lightBackgroundColor = const Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFD73A49);
  static ThemeData get lightTheme => ThemeData(
        primaryColor: lightBackgroundColor,
        backgroundColor: lightBackgroundColor,
        scaffoldBackgroundColor: lightBackgroundColor,
        primaryColorLight: const Color(0xFFF1F1F1),
        buttonColor: const Color(0xFFECECEC),
        accentColor: const Color(0xFF6E7681),
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
        primaryColor: darkBackgroundColor,
        backgroundColor: darkBackgroundColor,
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
          headline1: TextStyle(color: Colors.white),
          headline2: TextStyle(color: Colors.white),
          bodyText1: TextStyle(color: Colors.white),
          bodyText2: TextStyle(color: Colors.white),
        ),
      );
}
