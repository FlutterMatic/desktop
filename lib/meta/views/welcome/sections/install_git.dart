import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/checks.dart';
import 'package:manager/core/libraries/components.dart';
import 'package:provider/provider.dart';

Widget installGit(
  BuildContext context, {
  VoidCallback? onInstall,
  VoidCallback? onContinue,
  VoidCallback? onCancel,
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
        const SizedBox(height: 30),
        if (isInstalling && !doneInstalling)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: (gitNotifier.progress == Progress.STARTED ||
                    gitNotifier.progress == Progress.CHECKING)
                ? Column(
                    children: <Widget>[
                      hLoadingIndicator(
                        context: context,
                        message: 'Checking for git',
                      ),
                      const Text('Checking for git'),
                    ],
                  )
                : (gitNotifier.progress == Progress.DOWNLOADING)
                    ? CustomProgressIndicator(
                        disabled: (gitNotifier.progress != Progress.CHECKING &&
                            gitNotifier.progress != Progress.DOWNLOADING &&
                            gitNotifier.progress != Progress.STARTED),
                        progress: gitNotifier.progress,
                        toolName: 'Git',
                        onCancel: onCancel,
                        message: 'Downloading git',
                      )
                    : gitNotifier.progress == Progress.EXTRACTING
                        ? Tooltip(
                          message: 'Extracting git',
                          child: Lottie.asset(
                              Assets.extracting,
                              height: 100,
                            ),
                        )
                        : gitNotifier.progress == Progress.DONE
                            ? welcomeToolInstalled(
                                context,
                                title: 'Git Installed',
                                message:
                                    'Git installed successfully on your machine. Continue to the next step.',
                              )
                            : gitNotifier.progress == Progress.NONE
                                ? const SizedBox.shrink()
                                : CustomProgressIndicator(
                                    disabled: (gitNotifier.progress !=
                                            Progress.CHECKING &&
                                        gitNotifier.progress !=
                                            Progress.DOWNLOADING &&
                                        gitNotifier.progress !=
                                            Progress.STARTED),
                                    progress: gitNotifier.progress,
                                    toolName: 'Git',
                                    onCancel: onCancel,
                                    message: 'Downloading git',
                                  ),
          ),
        if (doneInstalling)
          welcomeToolInstalled(
            context,
            title: 'Git Installed',
            message: 'You have successfully installed Git.',
          ),
        if (gitNotifier.progress == Progress.DONE) const SizedBox(height: 30),
        WelcomeButton(
          onContinue: onContinue,
          onInstall: onInstall,
          progress: gitNotifier.progress,
          toolName: 'Git',
        ),
      ],
    );
  });
}
