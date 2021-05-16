import 'package:flutter/material.dart';
import 'package:flutter_installer/components/widgets/rectangle_button.dart';
import 'package:flutter_installer/services/themes.dart';
import 'package:flutter_installer/utils/constants.dart';

class ThemeSettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Themes',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 15),
        _themeTiles(context, !currentTheme.isDarkTheme, 'Light Mode',
            'Get a bright and shining desktop', () {
          if (currentTheme.isDarkTheme) currentTheme.toggleTheme();
        }),
        const SizedBox(height: 10),
        _themeTiles(context, currentTheme.isDarkTheme, 'Dark Mode',
            'For dark and nighty appearence', () {
          if (!currentTheme.isDarkTheme) currentTheme.toggleTheme();
        }),
      ],
    );
  }
}

Widget _themeTiles(BuildContext context, bool selected, String title,
    String description, Function() onPressed) {
  ThemeData customTheme = Theme.of(context);
  return RectangleButton(
    height: 65,
    width: double.infinity,
    hoverColor: Colors.transparent,
    onPressed: onPressed,
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
                  style: TextStyle(
                      color: customTheme.textTheme.bodyText1!.color,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
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
          selected
              ? const Icon(Icons.check_rounded, color: kGreenColor)
              : const SizedBox.shrink()
        ],
      ),
    ),
  );
}

