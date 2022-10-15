// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/shared_pref.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/theme.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/general/shared_pref.dart';

class ThemeNotifier extends StateNotifier<ThemeState> {
  final Ref ref;

  ThemeNotifier(this.ref) : super(ThemeState.initial());

  /// [_isDarkTheme] boolean value that indicates
  /// whether the app is currently in DarkTheme mode.
  bool _isDarkTheme = true;
  bool _isSystemTheme = false;

  // TODO: In initstate, load the preferred theme.

  void loadThemePref() {
    _isSystemTheme = SharedPref().pref.getBool(SPConst.isSystemTheme) ?? false;

    if (_isSystemTheme) {
      Brightness brightness =
          SchedulerBinding.instance.window.platformBrightness;

      _isDarkTheme = brightness == Brightness.dark;
    } else {
      if (SharedPref().pref.containsKey(SPConst.isDarkTheme)) {
        darkTheme = SharedPref().pref.getBool(SPConst.isDarkTheme)!;
      } else {
        darkTheme = true;
        SharedPref().pref.setBool(SPConst.isDarkTheme, true);
      }
    }
  }

  /// DarkTheme setter
  set darkTheme(bool value) {
    state = state.copyWith(
      darkTheme: value,
    );

    logger.file(LogTypeTag.info, 'Dark theme setter set to $value.');
  }

  Future<void> updateTheme(bool isDarkTheme) async {
    state = state.copyWith(
      darkTheme: isDarkTheme,
    );

    await SharedPref().pref.setBool(SPConst.isDarkTheme, _isDarkTheme);
    await logger.file(LogTypeTag.info, 'Dark theme updated to $_isDarkTheme.');
  }

  Future<void> updateSystemTheme(bool isSystemTheme) async {
    state = state.copyWith(
      systemTheme: isSystemTheme,
    );

    await SharedPref().pref.setBool(SPConst.isSystemTheme, _isSystemTheme);
    await logger.file(
        LogTypeTag.info, 'System theme updated to $_isSystemTheme.');
  }
}
