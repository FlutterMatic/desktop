// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:provider/src/provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/notifiers/theme.notifier.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';

Widget windowControls(BuildContext context, {bool disabled = false}) {
  return IgnorePointer(
    ignoring: disabled,
    child: AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: disabled ? 0.2 : 1,
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
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
      ),
    ),
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
      child: Icon(
        icon,
        size: 15,
        color: !context.watch<ThemeChangeNotifier>().isDarkTheme
            ? AppTheme.lightTheme.iconTheme.color
            : AppTheme.darkTheme.iconTheme.color,
      ),
    ),
  );
}

enum _HoverType { red, normal }
