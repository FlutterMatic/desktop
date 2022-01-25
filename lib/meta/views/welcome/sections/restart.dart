// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:url_launcher/url_launcher.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/shared_pref.dart';
import 'package:fluttermatic/core/libraries/components.dart';
import 'package:fluttermatic/core/libraries/constants.dart';
import 'package:fluttermatic/core/libraries/utils.dart';
import 'package:fluttermatic/core/libraries/views.dart';
import 'package:fluttermatic/core/libraries/widgets.dart';
import 'package:fluttermatic/core/services/logs.dart';

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
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const FMaticDocumentationDialog(),
                      );
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
          'You will need to restart your device to fully complete this setup. Make sure to save all your work before restarting.'),
      VSeparators.large(),
      WelcomeButton(
        onContinue: () {},
        onInstall: onRestart,
        progress: Progress.none,
        buttonText: 'Restart',
      ),
      VSeparators.small(),
      TextButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder<Widget>(
              pageBuilder: (_, __, ___) => const HomeScreen(),
              transitionDuration: Duration.zero,
            ),
          );
          SharedPref().pref.setBool(SPConst.completedSetup, true);
          SharedPref().pref.remove(SPConst.setupTab);
          logger.file(LogTypeTag.info, 'Skipping restart after setup.');
        },
        child: const Text('Skip'),
      )
    ],
  );
}
