import 'package:flutter/material.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/meta/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:manager/core/libraries/components.dart';

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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Flutter App Manager',
                    style: TextStyle(
                      fontSize: 12,
                      color: !context.read<ThemeChangeNotifier>().isDarkTheme
                          ? AppTheme.darkBackgroundColor
                          : AppTheme.lightBackgroundColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
                Expanded(child: MoveWindow()),
                windowControls(context)
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
