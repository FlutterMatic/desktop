import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:provider/provider.dart';
import 'package:manager/main.dart';

class ThemeSettingsSection extends StatefulWidget {
  const ThemeSettingsSection({Key? key}) : super(key: key);

  @override
  _ThemeSettingsSectionState createState() => _ThemeSettingsSectionState();
}

class _ThemeSettingsSectionState extends State<ThemeSettingsSection> {
  @override
  Widget build(BuildContext context) {
    return TabViewTabHeadline(
      // TODO: Fix the theme switching issue that persists in settings/theme tab. 
      title: 'Themes',
      content: <Widget>[
        _themeTiles(context, !context.read<ThemeChangeNotifier>().isDarkTheme,
            'Light Mode', 'Get a bright and shining desktop', () {
          if (context.read<ThemeChangeNotifier>().isDarkTheme) {
            context.read<ThemeChangeNotifier>().updateTheme(false);
            // We will restart the app for the theme to fully take place.
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Spinner(),
            );
            RestartWidget.restartApp(context);
          }
        }),
        VSeparators.small(),
        _themeTiles(
          context,
          context.read<ThemeChangeNotifier>().isDarkTheme,
          'Dark Mode',
          'For dark and nighty appearance',
          () {
            if (!context.read<ThemeChangeNotifier>().isDarkTheme) {
              context.read<ThemeChangeNotifier>().updateTheme(true);
              // We will restart the app for the theme to fully take place.
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Spinner(),
              );
              RestartWidget.restartApp(context);
            }
          },
        ),
      ],
    );
  }
}

Widget _themeTiles(BuildContext context, bool selected, String title,
    String description, Function() onPressed) {
  ThemeData customTheme = Theme.of(context);
  return RectangleButton(
    height: 65,
    onPressed: onPressed,
    width: double.infinity,
    hoverColor: Colors.transparent,
    focusColor: Colors.transparent,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    padding: const EdgeInsets.all(10),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style:
                      TextStyle(color: customTheme.textTheme.bodyText1!.color),
                ),
                VSeparators.xSmall(),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: customTheme.textTheme.bodyText1!.color!
                          .withOpacity(0.6)),
                ),
              ],
            ),
          ),
          if (selected) const Icon(Icons.check_rounded, color: kGreenColor),
        ],
      ),
    ),
  );
}
