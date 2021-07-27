
import 'package:flutter/material.dart';
import 'package:manager/app/constants/enum.dart';

Widget createWelcomeHeader(ThemeData theme, WelcomeTab tab) {
  Widget _title(String title, WelcomeTab tileTab) {
    return Expanded(
      child: tab == tileTab
          ? AnimatedContainer(
              duration: const Duration(seconds: 5),
              child: Column(
                children: [
                  Text(title),
                  const SizedBox(height: 20),
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: theme.textTheme.headline1!.color,
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
          children: [
            Container(
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xff757575),
              ),
            ),
            Row(
              children: [
                _title('Getting Started', WelcomeTab.Getting_Started),
                _title('Install Flutter', WelcomeTab.Install_Flutter),
                _title('Install Editor', WelcomeTab.Install_Editor),
                _title('Install Git', WelcomeTab.Install_Git),
                _title('Install Java', WelcomeTab.Install_Java),
                _title('Restart', WelcomeTab.Restart),
              ],
            )
          ],
        ),
      ),
    ),
  );
}
