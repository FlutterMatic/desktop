import 'package:flutter/material.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/meta/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:manager/meta/views/welcome/components/windows_controls.dart';

class CustomWindow extends StatelessWidget {
  final Widget child;

  CustomWindow({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.read<ThemeChangeNotifier>().isDarkTheme
          ? AppTheme.darkBackgroundColor
          : AppTheme.lightBackgroundColor,
      child: Column(
        children: <Widget>[
          WindowTitleBarBox(
            child: Row(
              children: <Widget>[
                Expanded(child: MoveWindow()),
                const WindowControls()
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
