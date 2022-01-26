// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/tab_view.dart';
import 'package:fluttermatic/core/notifiers/theme.notifier.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';

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
      allowContentScroll: false,
      content: <Widget>[
        _themeTiles(
          context,
          selected: !Theme.of(context).isDarkTheme &&
              !ThemeChangeNotifier().isSystemTheme,
          title: 'Light Mode',
          description: 'Get a bright and shining desktop',
          onPressed: () {
            if (Theme.of(context).isDarkTheme) {
              context.read<ThemeChangeNotifier>().updateTheme(
                  Theme.of(context).brightness == Brightness.light);
            }
          },
        ),
        VSeparators.small(),
        _themeTiles(
          context,
          selected: Theme.of(context).isDarkTheme &&
              !ThemeChangeNotifier().isSystemTheme,
          title: 'Dark Mode',
          description: 'For dark and nighty appearance',
          onPressed: () {
            if (!Theme.of(context).isDarkTheme) {
              context.read<ThemeChangeNotifier>().updateTheme(
                  Theme.of(context).brightness == Brightness.light);
            }
          },
        ),
        const Spacer(),
        Align(
          alignment: Alignment.centerRight,
          child: SelectableText(
            appVersion + ' - ' + appBuild,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

Widget _themeTiles(
  BuildContext context, {
  required bool selected,
  required String title,
  required String description,
  required Function() onPressed,
}) {
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
                Text(title),
                VSeparators.xSmall(),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
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
