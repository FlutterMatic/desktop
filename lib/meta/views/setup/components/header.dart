// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/enum.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/theme.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/meta/utils/general/app_theme.dart';

Widget createSetUpHeader(SetUpTab tab, BuildContext context) {
  Widget headerTitle(String title, SetUpTab tileTab) {
    if (tab == tileTab) {
      return Expanded(
        child: Column(
          children: <Widget>[
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            VSeparators.large(),
            Consumer(
              builder: (_, ref, __) {
                ThemeState themeState = ref.watch(themeStateController);

                return Container(
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: themeState.darkTheme
                        ? AppTheme.lightBackgroundColor
                        : AppTheme.darkBackgroundColor,
                  ),
                );
              },
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
            Consumer(
              builder: (_, ref, __) {
                ThemeState themeState = ref.watch(themeStateController);

                return Container(
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: themeState.darkTheme
                        ? const Color(0xff1B2529)
                        : const Color(0xFFF4F8FA),
                  ),
                );
              },
            ),
            Row(
              children: <Widget>[
                headerTitle('Getting Started', SetUpTab.gettingStarted),
                headerTitle('Install Flutter', SetUpTab.installFlutter),
                headerTitle('Install Editor', SetUpTab.installEditor),
                headerTitle('Install Git', SetUpTab.installGit),
                headerTitle('Install Java', SetUpTab.installJava),
                headerTitle('Restart', SetUpTab.restart),
              ],
            )
          ],
        ),
      ),
    ),
  );
}
