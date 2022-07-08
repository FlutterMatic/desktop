// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/enum.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/bullet_point.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/core/notifiers/models/state/checks/java.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/theme.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/meta/utils/general/app_theme.dart';
import 'package:fluttermatic/meta/views/setup/components/button.dart';
import 'package:fluttermatic/meta/views/setup/components/header_title.dart';
import 'package:fluttermatic/meta/views/setup/components/loading_indicator.dart';
import 'package:fluttermatic/meta/views/setup/components/progress_indicator.dart';
import 'package:fluttermatic/meta/views/setup/components/tool_installed.dart';

Widget installJava(
  BuildContext context, {
  required VoidCallback onInstall,
  required VoidCallback onContinue,
  required VoidCallback onSkip,
  required bool isInstalling,
  required bool doneInstalling,
}) {
  return Consumer(
    builder: (_, ref, __) {
      JavaState javaState = ref.watch(javaNotifierController);

      ThemeState themeState = ref.watch(themeStateController);

      return Column(
        children: <Widget>[
          setUpHeaderTitle(
            Assets.java,
            'Install Java',
            'Java is sometimes needed in Flutter development. However you can skip if you do not want to install Java.',
            iconHeight: 40,
          ),
          VSeparators.normal(),
          Builder(
            builder: (_) {
              if (javaState.progress == Progress.started ||
                  javaState.progress == Progress.checking) {
                return hLoadingIndicator(context: context);
              } else if (javaState.progress == Progress.downloading) {
                return const CustomProgressIndicator();
              } else if (javaState.progress == Progress.extracting) {
                return hLoadingIndicator(context: context);
              } else if (javaState.progress == Progress.done) {
                return setUpToolInstalled(
                  context,
                  title:
                      'Java Installed - v${javaState.javaVersion ?? 'Unknown'}',
                  message:
                      'Java installed successfully on your device. Continue to the next step.',
                );
              } else if (javaState.progress == Progress.none) {
                return infoWidget(context,
                    'Java can be essential for Android development. We recommend installing Java if you will be developing Android apps.');
              } else if (javaState.progress == Progress.done) {
                return setUpToolInstalled(
                  context,
                  title:
                      'Java Installed - v${javaState.javaVersion ?? 'Unknown'}',
                  message:
                      'You have successfully installed Java. Click continue to wrap up.',
                );
              } else {
                return const CustomProgressIndicator();
              }
            },
          ),
          VSeparators.normal(),
          SetUpButton(
            onContinue: onContinue,
            onInstall: onInstall,
            progress: javaState.progress,
          ),
          VSeparators.large(),
          if (javaState.progress == Progress.none)
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
                                hoverColor: AppTheme.errorColor,
                                onPressed: () {
                                  Navigator.pop(context);
                                  onSkip();
                                },
                                child: Text(
                                  'Skip',
                                  style: TextStyle(
                                      color: themeState.isDarkTheme
                                          ? Colors.white
                                          : Colors.black),
                                ),
                              ),
                            ),
                            HSeparators.small(),
                            Expanded(
                              child: RectangleButton(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                      color: themeState.isDarkTheme
                                          ? Colors.white
                                          : Colors.black),
                                ),
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
