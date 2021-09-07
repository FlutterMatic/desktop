import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/dialog_templates/settings/settings.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:provider/provider.dart';

class ThemeSettingsSection extends StatefulWidget {
  @override
  _ThemeSettingsSectionState createState() => _ThemeSettingsSectionState();
}

class _ThemeSettingsSectionState extends State<ThemeSettingsSection> {
  @override
  Widget build(BuildContext context) {
    return TabViewTabHeadline(
      title: 'Themes',
      content: <Widget>[
        _themeTiles(context, !context.read<ThemeChangeNotifier>().isDarkTheme,
            'Light Mode', 'Get a bright and shining desktop', () {
          if (context.read<ThemeChangeNotifier>().isDarkTheme) {
            context.read<ThemeChangeNotifier>().updateTheme(false);
            setState(() {});
            // We will exit the settings page and re-open it to update the theme
            // for the settings dialog. The user won't really see this happening.
            Navigator.pop(context);
            showDialog(context: context, builder: (_) => const SettingDialog());
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
            setState(() {});
              // We will exit the settings page and re-open it to update the theme
              // for the settings dialog. The user won't really see this happening.
              Navigator.pop(context);
              showDialog(
                  context: context, builder: (_) => const SettingDialog());
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
