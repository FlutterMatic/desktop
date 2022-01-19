// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:manager/core/libraries/checks.dart';
import 'package:manager/core/libraries/components.dart';
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/meta/utils/app_theme.dart';

Widget installJava(
  BuildContext context, {
  required VoidCallback onInstall,
  required VoidCallback onContinue,
  required VoidCallback onSkip,
  required bool isInstalling,
  required bool doneInstalling,
}) {
  return Consumer<JavaNotifier>(
    builder: (BuildContext context, JavaNotifier javaNotifier, _) {
      return Column(
        children: <Widget>[
          welcomeHeaderTitle(
            Assets.java,
            'Install Java',
            'Java is sometimes needed in Flutter development. However you can skip if you do not want to install Java.',
            iconHeight: 40,
          ),
          VSeparators.normal(),
          Builder(
            builder: (_) {
              if (javaNotifier.progress == Progress.started ||
                  javaNotifier.progress == Progress.checking) {
                return hLoadingIndicator(context: context);
              } else if (javaNotifier.progress == Progress.downloading) {
                return const CustomProgressIndicator();
              } else if (javaNotifier.progress == Progress.extracting) {
                return hLoadingIndicator(context: context);
              } else if (javaNotifier.progress == Progress.done) {
                return welcomeToolInstalled(
                  context,
                  title:
                      'Java Installed - v${javaNotifier.javaVersion ?? 'Unknown'}',
                  message:
                      'Java installed successfully on your device. Continue to the next step.',
                );
              } else if (javaNotifier.progress == Progress.none) {
                return infoWidget(context,
                    'Java can be essential for Android development. We recommend installing Java if you will be developing Android apps.');
              } else if (javaNotifier.progress == Progress.done) {
                return welcomeToolInstalled(
                  context,
                  title:
                      'Java Installed - v${javaNotifier.javaVersion ?? 'Unknown'}',
                  message:
                      'You have successfully installed Java. Click continue to wrap up.',
                );
              } else {
                return const CustomProgressIndicator();
              }
            },
          ),
          VSeparators.normal(),
          WelcomeButton(
            onContinue: onContinue,
            onInstall: onInstall,
            progress: javaNotifier.progress,
          ),
          VSeparators.large(),
          if (javaNotifier.progress == Progress.none)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => DialogTemplate(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const DialogHeader(title: 'Are you sure?'),
                        informationWidget(
                          'We recommend that you installed Java. This will help eliminate some issues you might face in the future with Flutter.',
                        ),
                        VSeparators.normal(),
                        infoWidget(context,
                            'You will still be able to install Java later if you change your mind.'),
                        VSeparators.large(),
                        const Text('Tool Skipping:'),
                        VSeparators.normal(),
                        const BulletPoint('Java 8 by Oracle', 2),
                        VSeparators.large(),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: RectangleButton(
                                child: Text(
                                  'Skip',
                                  style: TextStyle(
                                      color: context
                                              .read<ThemeChangeNotifier>()
                                              .isDarkTheme
                                          ? Colors.white
                                          : Colors.black),
                                ),
                                hoverColor: AppTheme.errorColor,
                                color: Colors.blueGrey.withOpacity(0.2),
                                onPressed: () {
                                  Navigator.pop(context);
                                  onSkip();
                                },
                              ),
                            ),
                            HSeparators.small(),
                            Expanded(
                              child: RectangleButton(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                      color: context
                                              .read<ThemeChangeNotifier>()
                                              .isDarkTheme
                                          ? Colors.white
                                          : Colors.black),
                                ),
                                color: Colors.blueGrey.withOpacity(0.2),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('Skip', style: TextStyle(fontSize: 12)),
              ),
            ),
        ],
      );
    },
  );
}
