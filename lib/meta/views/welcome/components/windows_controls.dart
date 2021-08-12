import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:provider/provider.dart';

class WindowControls extends StatelessWidget {
  final bool disabled;

  const WindowControls({Key? key, this.disabled = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              _Control(
                icon: Icons.remove_rounded,
                onPressed: () => appWindow.minimize(),
              ),
              _Control(
                icon: Icons.crop_square_rounded,
                onPressed: () => appWindow.maximizeOrRestore(),
              ),
              _Control(
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
}

class _Control extends StatelessWidget {
  final IconData icon;
  final Function() onPressed;
  final _HoverType hoverType;

  const _Control({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.hoverType = _HoverType.normal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: MaterialButton(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        hoverColor: hoverType == _HoverType.normal
            ? Colors.white.withOpacity(0.2)
            : Colors.red[500],
        onPressed: onPressed,
        child: Icon(
          icon,
          size: 15,
          color: context.read<ThemeChangeNotifier>().isDarkTheme
              ? Colors.white
              : Colors.black,
        ),
      ),
    );
  }
}

enum _HoverType { red, normal }
