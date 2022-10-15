// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/notifiers/models/state/general/connection.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/theme.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/meta/utils/general/app_theme.dart';

Widget windowControls(BuildContext context, {bool disabled = false}) {
  return Consumer(
    builder: (_, ref, __) {
      NetworkState connectionState = ref.watch(connectionNotifierController);

      return IgnorePointer(
        ignoring: disabled,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: disabled ? 0.2 : 1,
          child: Row(
            children: [
              if (!connectionState.connected)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red),
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'No network connection.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _control(
                    context,
                    icon: Icons.remove_rounded,
                    onPressed: () => appWindow.minimize(),
                  ),
                  _control(
                    context,
                    icon: Icons.crop_square_rounded,
                    onPressed: () => appWindow.maximizeOrRestore(),
                  ),
                  _control(
                    context,
                    icon: Icons.close_rounded,
                    onPressed: () => appWindow.close(),
                    hoverType: _HoverType.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _control(
  BuildContext context, {
  required IconData icon,
  required VoidCallback onPressed,
  _HoverType hoverType = _HoverType.normal,
}) {
  return SizedBox(
    width: 40,
    child: MaterialButton(
      focusColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: hoverType == _HoverType.normal
          ? Colors.blueGrey.withOpacity(0.2)
          : AppTheme.errorColor,
      onPressed: onPressed,
      child: Consumer(
        builder: (_, ref, __) {
          ThemeState themeState = ref.watch(themeStateController);

          return Icon(
            icon,
            size: 15,
            color: !themeState.darkTheme
                ? AppTheme.lightTheme.iconTheme.color
                : AppTheme.darkTheme.iconTheme.color,
          );
        },
      ),
    ),
  );
}

enum _HoverType { red, normal }
