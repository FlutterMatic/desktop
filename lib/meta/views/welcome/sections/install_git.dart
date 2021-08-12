import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/meta/views/welcome/components/tool_installed.dart';
import 'package:provider/provider.dart';
import 'package:manager/meta/views/welcome/components/button.dart';
import 'package:manager/meta/views/welcome/components/header_title.dart';
import 'package:manager/meta/views/welcome/components/progress_indicator.dart';

Widget installGit(
  BuildContext context,
  VoidCallback? onInstall, {
  required bool isInstalling,
  required bool doneInstalling,
}) {
  return Column(
    children: <Widget>[
      welcomeHeaderTitle(
        Assets.git,
        Install.git,
        InstallContent.git,
      ),
      const SizedBox(height: 30),
      if (!doneInstalling)
        installProgressIndicator(
          disabled: !isInstalling,
          objectSize: '3.2 GB',
        )
      else
        welcomeToolInstalled(
          context,
          title: 'Git Installed',
          message:
              'You have successfully installed Git. Click next to continue.',
        ),
      const SizedBox(height: 30),
      WelcomeButton(
        onCancel: () {},
        onContinue: () {},
        onInstall: () {},
        progress: Progress.NONE,
        toolName: 'Git',
      ),
    ],
  );
}
