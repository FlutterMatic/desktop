import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:provider/provider.dart';
import 'package:manager/meta/views/welcome/components/button.dart';
import 'package:manager/meta/views/welcome/components/header_title.dart';

Widget welcomeRestart(BuildContext context, Function() onRestart) {
  return Column(
    children: <Widget>[
      welcomeHeaderTitle(
        Assets.confetti,
        Installed.congos,
        InstalledContent.allDone,
      ),
      const SizedBox(height: 30),
      Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: context.read<ThemeChangeNotifier>().isDarkTheme
              ? const Color(0xff1B2529)
              : const Color(0xffF4F8FA),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Documentation', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            const Text(
              InstallContent.docs,
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: MaterialButton(
                    height: 50,
                    color: const Color(0xff40CAFF).withOpacity(0.3),
                    elevation: 0,
                    hoverElevation: 0,
                    onPressed: () {},
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Flutter Documentation',
                      style: TextStyle(
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MaterialButton(
                    height: 50,
                    color: const Color(0xff40CAFF).withOpacity(0.3),
                    onPressed: () {},
                    elevation: 0,
                    hoverElevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Our Documentation',
                      style: TextStyle(
                        color: Color(
                          0xff40CAFF,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 30),
      WelcomeButton(ButtonTexts.restart, onRestart),
    ],
  );
}
