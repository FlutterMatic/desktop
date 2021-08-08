import 'package:flutter/material.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/meta/utils/app_theme.dart';
import 'package:provider/provider.dart';

Widget createWelcomeHeader(
    ThemeData theme, WelcomeTab tab, BuildContext context) {
  Widget _title(String title, WelcomeTab tileTab) {
    return Expanded(
      child: tab == tileTab
          ? AnimatedContainer(
              duration: const Duration(seconds: 5),
              child: Column(
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedContainer(
                    duration: const Duration(seconds: 5),
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: AppTheme.lightComponentsColor,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  return Padding(
    padding: const EdgeInsets.only(top: 30),
    child: Center(
      child: SizedBox(
        width: 800,
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: <Widget>[
            AnimatedContainer(
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: context.read<ThemeChangeNotifier>().isDarkTheme
                    ? const Color(0xff1B2529)
                    : const Color(0xFFF4F8FA),
              ),
              duration: const Duration(seconds: 1),
            ),
            Row(
              children: <Widget>[
                _title('Getting Started', WelcomeTab.GETTING_STARTED),
                _title('Install Flutter', WelcomeTab.INSTALL_FLUTTER),
                _title('Install Editor', WelcomeTab.INSTALL_EDITOR),
                _title('Install Git', WelcomeTab.INSTALL_GIT),
                _title('Install Java', WelcomeTab.INSTALL_JAVA),
                _title('Restart', WelcomeTab.RESTART),
              ],
            )
          ],
        ),
      ),
    ),
  );
}
