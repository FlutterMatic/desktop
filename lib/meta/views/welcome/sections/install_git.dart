import 'package:flutter/material.dart';
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
        VSeparators.xLarge(),
        if (isInstalling && !doneInstalling)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: (gitNotifier.progress == Progress.started ||
                    gitNotifier.progress == Progress.checking)
                ? Column(
                    children: <Widget>[
                      hLoadingIndicator(
                        context: context,
                      ),
                      const Text('Checking for git'),
                    ],
                  )
                : (gitNotifier.progress == Progress.downloading)
                    ? CustomProgressIndicator(
                        disabled: (gitNotifier.progress != Progress.checking &&
                            gitNotifier.progress != Progress.downloading &&
                            gitNotifier.progress != Progress.started),
                        progress: gitNotifier.progress,
                        toolName: 'Git',
                        onCancel: onCancel,
                        message: 'Downloading git',
                      )
                    : gitNotifier.progress == Progress.extracting
                        ? Column(
                            children: <Widget>[
                              hLoadingIndicator(
                                context: context,
                              ),
                              const Text('Extracting git'),
                            ],
                          )
                        : gitNotifier.progress == Progress.done
                            ? welcomeToolInstalled(
                                context,
                                title: 'Git Installed',
                                message:
                                    'Git installed successfully on your machine. Continue to the next step.',
                              )
                            : gitNotifier.progress == Progress.none
                                ? const SizedBox.shrink()
                                : CustomProgressIndicator(
                                    disabled: (gitNotifier.progress !=
                                            Progress.checking &&
                                        gitNotifier.progress !=
                                            Progress.downloading &&
                                        gitNotifier.progress !=
                                            Progress.started),
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
        VSeparators.xLarge(),
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
