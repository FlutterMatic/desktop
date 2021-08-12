import 'package:flutter/material.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:provider/provider.dart';
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
        color: context.read<ThemeChangeNotifier>().isDarkTheme
            ? null
            : Colors.black,
      ),
      const SizedBox(height: 30),
      RoundContainer(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(InstallContent.docs, style: TextStyle(fontSize: 13)),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: RectangleButton(
                    child: const Text('Flutter Documentation',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RectangleButton(
                    child: const Text('Our Documentation',
                        style: TextStyle(color: Colors.white)),
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
        'You will need to restart your computer to fully complete this setup. Make sure to save all your work before restarting.',
        Assets.warn,
        kYellowColor,
      ),
      const SizedBox(height: 20),
      WelcomeButton(
        onCancel: () {},
        onContinue: () {},
        onInstall: () {},
        progress: Progress.NONE,
        toolName: 'Flutter',
        buttonText: 'Restart',
      ),
    ],
  );
}
