// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:manager/core/libraries/checks.dart';
import 'package:manager/core/libraries/components.dart';
import 'package:manager/core/libraries/constants.dart';

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
          'Install Git',
          'Flutter relies on Git to get and install dependencies and other tools.',
        ),
        VSeparators.normal(),
        Builder(
          builder: (_) {
            if (gitNotifier.progress == Progress.started ||
                gitNotifier.progress == Progress.checking) {
              return hLoadingIndicator(context: context);
            } else if (gitNotifier.progress == Progress.downloading) {
              return const CustomProgressIndicator();
            } else if (gitNotifier.progress == Progress.extracting) {
              return hLoadingIndicator(context: context);
            } else if (gitNotifier.progress == Progress.none) {
              return infoWidget(context,
                  'Git will be used to provide services such as Pub and other tools that Flutter & Dart uses.');
            } else if (gitNotifier.progress == Progress.done) {
              return welcomeToolInstalled(
                context,
                title:
                    'Git Installed - v${gitNotifier.gitVersion ?? 'Unknown'}',
                message:
                    'You have successfully installed Git. Click next to continue.',
              );
            } else {
              return hLoadingIndicator(context: context);
            }
          },
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
