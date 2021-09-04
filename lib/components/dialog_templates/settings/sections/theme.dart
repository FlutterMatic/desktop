import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/widgets.dart';

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
        // TODO: Show the theme selector.
        VSeparators.normal(),
        // _themeTiles(context, !currentTheme.isDarkTheme, 'Light Mode',
        //     'Get a bright and shining desktop', () {
        // if (currentTheme.isDarkTheme) currentTheme.toggleTheme();
        // }),
        VSeparators.small(),
        // _themeTiles(context, currentTheme.isDarkTheme, 'Dark Mode',
        //     'For dark and nighty appearance', () {
        //   if (!currentTheme.isDarkTheme) currentTheme.toggleTheme();
        // }),
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
    focusColor: Colors.transparent,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
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
          selected
              ? const Icon(Icons.check_rounded, color: kGreenColor)
              : const SizedBox.shrink()
        ],
      ),
    ),
  );
}
