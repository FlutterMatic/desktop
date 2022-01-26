// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/app/constants/enum.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/core/services/checks/git.check.dart';
import 'package:fluttermatic/meta/views/setup/components/button.dart';
import 'package:fluttermatic/meta/views/setup/components/header_title.dart';
import 'package:fluttermatic/meta/views/setup/components/loading_indicator.dart';
import 'package:fluttermatic/meta/views/setup/components/progress_indicator.dart';
import 'package:fluttermatic/meta/views/setup/components/tool_installed.dart';

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
        setUpHeaderTitle(
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
              return setUpToolInstalled(
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
        SetUpButton(
          onContinue: onContinue,
          onInstall: onInstall,
          progress: gitNotifier.progress,
        ),
      ],
    );
  });
}
