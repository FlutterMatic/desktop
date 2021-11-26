// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:provider/src/provider.dart';

// 🌎 Project imports:
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/meta/utils/app_theme.dart';

AnimatedOpacity windowControls(BuildContext context, {bool disabled = false}) {
  return AnimatedOpacity(
    duration: const Duration(milliseconds: 300),
    opacity: disabled ? 0.2 : 1,
    child: IgnorePointer(
      ignoring: disabled,
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

Widget _control(BuildContext context,
    {required IconData icon, required VoidCallback onPressed, _HoverType hoverType = _HoverType.normal}) {
  return SizedBox(
    width: 40,
    child: MaterialButton(
      splashColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      hoverColor: hoverType == _HoverType.normal ? Colors.white.withOpacity(0.2) : Colors.red,
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
