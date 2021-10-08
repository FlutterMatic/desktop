// 📦 Package imports:
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  SharedPref._();
  factory SharedPref() => _instance;
  static final SharedPref _instance = SharedPref._();
  SharedPreferences? _pref;
  SharedPreferences get pref => _pref!;
  static Future<void> init() async {
    _instance._pref = await SharedPreferences.getInstance();
  }
}
