import 'package:flutter/material.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/meta/views/welcome/components/tool_installed.dart';
import 'package:manager/meta/views/welcome/components/button.dart';
import 'package:manager/meta/views/welcome/components/header_title.dart';
import 'package:manager/meta/views/welcome/components/progress_indicator.dart';

Widget installFlutter(
  BuildContext context, {
  required VoidCallback onInstall,
  required VoidCallback onCancel,
  VoidCallback? onContinue,
  required Progress progress,
}) {
  return Column(
    children: <Widget>[
      welcomeHeaderTitle(
        Assets.flutter,
        'Install Flutter',
        'You will need to install Flutter in your machine to start using Flutter.',
      ),
      const SizedBox(height: 50),
      // (progress == Progress.DOWNLOADING ||
      //         progress == Progress.EXTRACTING ||
      //         progress == Progress.STARTED)
      //     ?
      installProgressIndicator(
        objectSize: '1.8 GB',
        disabled: (progress != Progress.CHECKING &&
            progress != Progress.DOWNLOADING &&
            progress != Progress.STARTED),
        progress: Progress.NONE,
        toolName: 'Flutter',
        onCancel: onCancel,
      ),
      // : welcomeToolInstalled(
      //     context,
      //     title: 'Flutter Installed',
      //     message:
      //         'Flutter was installed successfully on your machine. Continue to the next step.',
      //   ),
      const SizedBox(height: 50),
      WelcomeButton(
        onContinue: onContinue,
        onInstall: onInstall,
        progress: Progress.NONE,
        toolName: 'Flutter',
      ),
    ],
  );
}
