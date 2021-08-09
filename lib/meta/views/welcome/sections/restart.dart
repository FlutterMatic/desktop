import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:manager/meta/utils/app_theme.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/meta/views/welcome/components/button.dart';
import 'package:manager/components/widgets/ui/warning_widget.dart';
import 'package:manager/components/widgets/ui/round_container.dart';
import 'package:manager/meta/views/welcome/components/header_title.dart';
import 'package:manager/components/widgets/buttons/rectangle_button.dart';

Widget welcomeRestart(BuildContext context, Function() onRestart) {
  return Column(
    children: <Widget>[
      welcomeHeaderTitle(
        Assets.confetti,
        Installed.congos,
        InstalledContent.allDone,
      ),
      const SizedBox(height: 30),
      RoundContainer(
        padding: const EdgeInsets.all(15),
        color: context.read<ThemeChangeNotifier>().isDarkTheme
            ? null
            : const Color(0xffF4F8FA),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(InstallContent.docs, style: TextStyle(fontSize: 13)),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: RectangleButton(
                    child: const Text(
                      'Flutter Documentation',
                      style: TextStyle(color: Colors.lightBlueAccent),
                    ),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RectangleButton(
                    child: const Text(
                      'Our Documentation',
                      style: TextStyle(color: Colors.lightBlueAccent),
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      warningWidget(
        'You will need to restart your computer to fully complete this setup.',
        Assets.warn,
        kYellowColor,
      ),
      const SizedBox(height: 20),
      WelcomeButton(ButtonTexts.restart, onRestart),
    ],
  );
}
