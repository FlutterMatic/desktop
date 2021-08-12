import 'package:flutter/material.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/meta/views/welcome/components/tool_installed.dart';
import 'package:manager/meta/views/welcome/components/button.dart';
import 'package:manager/meta/views/welcome/components/header_title.dart';
import 'package:manager/meta/views/welcome/components/progress_indicator.dart';

Widget installFlutter(
  BuildContext context,
  Function() onInstall, {
  required Function() onCancel,
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
      // TODO(@ZiyadF296) : Don't use opacity, instead shrink the space and when
      // user click install show them the checks happening and if the flutter sdk
      // not found then show the download progress.
      (progress == Progress.DOWNLOADING ||
              progress == Progress.EXTRACTING ||
              progress == Progress.STARTED)
          ? installProgressIndicator(
              objectSize: '1.8 GB',
              disabled: (progress != Progress.CHECKING &&
                  progress != Progress.DOWNLOADING &&
                  progress != Progress.STARTED),
            )
          : welcomeToolInstalled(
              context,
              title: 'Flutter Installed',
              message:
                  'Flutter was installed successfully on your machine. Continue to the next step.',
            ),
      const SizedBox(height: 50),
      WelcomeButton(
        onCancel: () {},
        onContinue: () {},
        onInstall: () {},
        progress: Progress.NONE,
        toolName: 'Flutter',
      ),
    ],
  );
}
