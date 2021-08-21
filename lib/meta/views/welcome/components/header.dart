import 'package:flutter/material.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/meta/utils/app_theme.dart';
import 'package:provider/provider.dart';

Widget createWelcomeHeader(
    ThemeData theme, WelcomeTab tab, BuildContext context) {
  Widget _title(String title, WelcomeTab tileTab) {
    if (tab == tileTab) {
      return Expanded(
        child: Column(
          children: <Widget>[
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 20),
            Container(
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppTheme.lightTheme.buttonColor,
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
                color: context.read<ThemeChangeNotifier>().isDarkTheme
                    ? const Color(0xff1B2529)
                    : const Color(0xFFF4F8FA),
              ),
            ),
            Row(
              children: <Widget>[
                _title('Getting Started', WelcomeTab.gettingStarted),
                _title('Install Flutter', WelcomeTab.installFlutter),
                _title('Install Editor', WelcomeTab.installEditor),
                _title('Install Git', WelcomeTab.installGit),
                _title('Install Java', WelcomeTab.installJava),
                _title('Restart', WelcomeTab.restart),
              ],
            )
          ],
        ),
      ),
    ),
  );
}
