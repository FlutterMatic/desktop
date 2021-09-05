import 'package:flutter/material.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/ui/info_widget.dart';
import 'package:manager/core/libraries/checks.dart';
import 'package:manager/core/libraries/components.dart';
import 'package:provider/provider.dart';

Widget installGit(
  BuildContext context, {
  VoidCallback? onInstall,
  VoidCallback? onContinue,
  required bool isInstalling,
  required bool doneInstalling,
}) {
  return Consumer<GitNotifier>(
      builder: (BuildContext context, GitNotifier gitNotifier, _) {
    return Column(
      children: <Widget>[
        welcomeHeaderTitle(
          Assets.git,
          Install.git,
          InstallContent.git,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: (gitNotifier.progress == Progress.started ||
                  gitNotifier.progress == Progress.checking)
              ? hLoadingIndicator(context: context)
              : gitNotifier.progress == Progress.downloading
                  ? CustomProgressIndicator()
                  : gitNotifier.progress == Progress.extracting
                      ? hLoadingIndicator(context: context)
                      : gitNotifier.progress == Progress.done
                          ? welcomeToolInstalled(
                              context,
                              title: 'Git Installed',
                              message:
                                  'Git installed successfully on your device. Continue to the next step.',
                            )
                          : gitNotifier.progress == Progress.none
                              ? infoWidget(context,
                                  'Git will be used to provide services such as Pub and other tools that Flutter & Dart uses.')
                              : hLoadingIndicator(context: context),
        ),
        if (doneInstalling)
          welcomeToolInstalled(
            context,
            title: 'Git Installed',
            message: 'You have successfully installed Git.',
          ),
        VSeparators.normal(),
        WelcomeButton(
          onContinue: onContinue,
          onInstall: onInstall,
          progress: gitNotifier.progress,
        ),
      ],
    );
  });
}
