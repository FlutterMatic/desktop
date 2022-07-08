// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/enum.dart';

// 🌎 Project imports:
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/core/notifiers/models/state/checks/git.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
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
  return Consumer(
    builder: (_, ref, __) {
      GitState gitState = ref.watch(gitNotifierController);

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
              if (gitState.progress == Progress.started ||
                  gitState.progress == Progress.checking) {
                return hLoadingIndicator(context: context);
              } else if (gitState.progress == Progress.downloading) {
                return const CustomProgressIndicator();
              } else if (gitState.progress == Progress.extracting) {
                return hLoadingIndicator(context: context);
              } else if (gitState.progress == Progress.none) {
                return infoWidget(context,
                    'Git will be used to provide services such as Pub and other tools that Flutter & Dart uses.');
              } else if (gitState.progress == Progress.done) {
                return setUpToolInstalled(
                  context,
                  title: 'Git Installed - v${gitState.gitVersion ?? 'Unknown'}',
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
            progress: gitState.progress,
          ),
        ],
      );
    },
  );
}
