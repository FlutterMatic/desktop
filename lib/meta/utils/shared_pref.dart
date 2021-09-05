import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  SharedPref._();
  factory SharedPref() => _instance;
  static final SharedPref _instance = SharedPref._();
  SharedPreferences? _prefs;
  SharedPreferences get pref => _prefs!;
  static Future<void> init() async {
    _instance._prefs = await SharedPreferences.getInstance();
  }
}
