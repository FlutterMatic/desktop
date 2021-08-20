import 'package:flutter/material.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:provider/provider.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/components.dart';
import 'package:manager/core/libraries/widgets.dart';

Widget welcomeRestart(BuildContext context, {VoidCallback? onRestart}) {
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
      informationWidget(
        InstalledContent.restart,
      ),
      const SizedBox(height: 20),
      WelcomeButton(
        onContinue: () {},
        onInstall: onRestart,
        progress: Progress.NONE,
        toolName: 'Flutter',
        buttonText: 'Restart',
      ),
    ],
  );
}
