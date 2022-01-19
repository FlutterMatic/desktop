// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:url_launcher/url_launcher.dart';

// 🌎 Project imports:
import 'package:manager/core/libraries/components.dart';
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/meta/utils/app_theme.dart';

Widget welcomeRestart(BuildContext context, {VoidCallback? onRestart}) {
  return Column(
    children: <Widget>[
      welcomeHeaderTitle(
        Assets.confetti,
        'Congrats',
        'All set! You will need to restart your device to start using Flutter.',
        color: Theme.of(context).isDarkTheme ? null : Colors.black,
      ),
      VSeparators.xLarge(),
      RoundContainer(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Read the official Flutter documentation or check our documentation for how to use this app.',
              style: TextStyle(fontSize: 13),
            ),
            VSeparators.large(),
            Row(
              children: <Widget>[
                Expanded(
                  child: RectangleButton(
                    color: Theme.of(context).isDarkTheme
                        ? null
                        : AppTheme.darkBackgroundColor,
                    child: const Text('Flutter Documentation',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () => launch('https://flutter.dev/docs'),
                  ),
                ),
                HSeparators.small(),
                Expanded(
                  child: RectangleButton(
                    color: Theme.of(context).isDarkTheme
                        ? null
                        : AppTheme.darkBackgroundColor,
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
      VSeparators.small(),
      informationWidget(
          'You will need to restart your device to fully complete this setup. Make sure to save all your work before restarting.'),
      VSeparators.large(),
      WelcomeButton(
        onContinue: () {},
        onInstall: onRestart,
        progress: Progress.none,
        buttonText: 'Restart',
      ),
    ],
  );
}
