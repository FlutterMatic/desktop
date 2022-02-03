// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:url_launcher/url_launcher.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/app/constants/enum.dart';
import 'package:fluttermatic/app/constants/shared_pref.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';
import 'package:fluttermatic/meta/utils/shared_pref.dart';
import 'package:fluttermatic/meta/views/dialogs/documentation.dart';
import 'package:fluttermatic/meta/views/setup/components/button.dart';
import 'package:fluttermatic/meta/views/setup/components/header_title.dart';
import 'package:fluttermatic/meta/views/tabs/home.dart';

Widget setUpRestart(BuildContext context, {VoidCallback? onRestart}) {
  return Column(
    children: <Widget>[
      setUpHeaderTitle(
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
                        builder: (_) => const DocumentationDialog(),
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
      SetUpButton(
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
