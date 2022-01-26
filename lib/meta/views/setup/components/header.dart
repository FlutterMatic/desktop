// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/app/constants/enum.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';

Widget createSetUpHeader(SetUpTab tab, BuildContext context) {
  Widget _title(String title, SetUpTab tileTab) {
    if (tab == tileTab) {
      return Expanded(
        child: Column(
          children: <Widget>[
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            VSeparators.large(),
            Container(
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).isDarkTheme
                    ? AppTheme.lightBackgroundColor
                    : AppTheme.darkBackgroundColor,
              ),
            ),
          ],
        ),
      );
    } else {
      return const Expanded(child: SizedBox.shrink());
    }
  }

  return Padding(
    padding: const EdgeInsets.only(top: 25),
    child: Center(
      child: SizedBox(
        width: 800,
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: <Widget>[
            Container(
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).isDarkTheme
                    ? const Color(0xff1B2529)
                    : const Color(0xFFF4F8FA),
              ),
            ),
            Row(
              children: <Widget>[
                _title('Getting Started', SetUpTab.gettingStarted),
                _title('Install Flutter', SetUpTab.installFlutter),
                _title('Install Editor', SetUpTab.installEditor),
                _title('Install Git', SetUpTab.installGit),
                _title('Install Java', SetUpTab.installJava),
                _title('Restart', SetUpTab.restart),
              ],
            )
          ],
        ),
      ),
    ),
  );
}
