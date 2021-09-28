import 'package:flutter/material.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/core/libraries/checks.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/core/libraries/components.dart';
import 'package:manager/meta/utils/app_theme.dart';
import 'package:provider/provider.dart';

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
          Install.java,
          InstallContent.java,
          iconHeight: 40,
        ),
        VSeparators.large(),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: (javaNotifier.progress == Progress.started ||
                  javaNotifier.progress == Progress.checking)
              ? hLoadingIndicator(context: context)
              : (javaNotifier.progress == Progress.downloading)
                  ? const CustomProgressIndicator()
                  : javaNotifier.progress == Progress.extracting
                      ? hLoadingIndicator(context: context)
                      : javaNotifier.progress == Progress.done
                          ? welcomeToolInstalled(
                              context,
                              title: 'Java Installed',
                              message:
                                  'Java installed successfully on your device. Continue to the next step.',
                            )
                          : javaNotifier.progress == Progress.none
                              ? infoWidget(context,
                                  'Java can be essential for Android development. We recommend installing Java if you will be developing Android apps.')
                              : const CustomProgressIndicator(),
        ),
        if (doneInstalling)
          welcomeToolInstalled(
            context,
            title: Installed.java,
            message: InstalledContent.java,
          ),
        VSeparators.xLarge(),
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
              child: Text(
                ButtonTexts.skip,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
      ],
    );
  });
}
