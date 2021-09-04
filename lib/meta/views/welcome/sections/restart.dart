import 'package:flutter/material.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:provider/provider.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/components.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

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
      VSeparators.xLarge(),
      RoundContainer(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(InstallContent.docs, style: TextStyle(fontSize: 13)),
            VSeparators.large(),
            Row(
              children: <Widget>[
                Expanded(
                  child: RectangleButton(
                    child: const Text('Flutter Documentation',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () => launch('https://flutter.dev/docs'),
                  ),
                ),
                HSeparators.small(),
                Expanded(
                  child: RectangleButton(
                    child: const Text('Our Documentation',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      // TODO: Create our own documentation on our website.
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      VSeparators.small(),
      informationWidget(
        InstalledContent.restart,
      ),
      VSeparators.large(),
      WelcomeButton(
        onContinue: () {},
        onInstall: onRestart,
        progress: Progress.none,
        toolName: 'Flutter',
        buttonText: 'Restart',
      ),
    ],
  );
}
