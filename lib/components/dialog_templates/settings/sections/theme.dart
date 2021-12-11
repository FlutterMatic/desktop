// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/utils.dart';
import 'package:manager/core/libraries/widgets.dart';

class ThemeSettingsSection extends StatefulWidget {
  const ThemeSettingsSection({Key? key}) : super(key: key);

  @override
  _ThemeSettingsSectionState createState() => _ThemeSettingsSectionState();
}

class _ThemeSettingsSectionState extends State<ThemeSettingsSection> {
  @override
  Widget build(BuildContext context) {
    return TabViewTabHeadline(
      title: 'Themes',
      content: <Widget>[
        _themeTiles(context, !Theme.of(context).isDarkTheme, 'Light Mode',
            'Get a bright and shining desktop', () {
          if (Theme.of(context).isDarkTheme) {
            context
                .read<ThemeChangeNotifier>()
                .updateTheme(Theme.of(context).brightness == Brightness.light);
          }
        }),
        VSeparators.small(),
        _themeTiles(
          context,
          Theme.of(context).isDarkTheme,
          'Dark Mode',
          'For dark and nighty appearance',
          () {
            if (!Theme.of(context).isDarkTheme) {
              context.read<ThemeChangeNotifier>().updateTheme(
                  Theme.of(context).brightness == Brightness.light);
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
