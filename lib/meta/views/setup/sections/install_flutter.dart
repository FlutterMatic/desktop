// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/enum.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/core/notifiers/models/state/checks/flutter.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/meta/views/setup/components/button.dart';
import 'package:fluttermatic/meta/views/setup/components/header_title.dart';
import 'package:fluttermatic/meta/views/setup/components/loading_indicator.dart';
import 'package:fluttermatic/meta/views/setup/components/progress_indicator.dart';
import 'package:fluttermatic/meta/views/setup/components/tool_installed.dart';

Widget installFlutter(
  BuildContext context, {
  VoidCallback? onContinue,
  required VoidCallback onInstall,
}) {
  return Consumer(
    builder: (_, ref, __) {
      FlutterState flutterState = ref.watch(flutterNotifierController);

      return Column(
        children: <Widget>[
          setUpHeaderTitle(
            Assets.flutter,
            'Install Flutter',
            'You will need to install Flutter in your device to start using Flutter.',
          ),
          VSeparators.xLarge(),
          Builder(
            builder: (_) {
              if (flutterState.progress == Progress.started ||
                  flutterState.progress == Progress.checking) {
                return hLoadingIndicator(context: context);
              } else if (flutterState.progress == Progress.downloading) {
                return const CustomProgressIndicator();
              } else if (flutterState.progress == Progress.extracting) {
                return hLoadingIndicator(context: context);
              } else if (flutterState.progress == Progress.none) {
                return infoWidget(context,
                    'We will check if you have Flutter installed or not and install it for you if you don\'t.');
              } else if (flutterState.progress == Progress.done) {
                return setUpToolInstalled(
                  context,
                  title:
                      'Flutter Installed - v${flutterState.flutterVersion ?? 'Unknown'}',
                  message:
                      'Flutter was installed successfully on your device. Continue to the next step.',
                );
              } else {
                return hLoadingIndicator(context: context);
              }
            },
          ),
          VSeparators.normal(),
          SetUpButton(
            onInstall: onInstall,
            onContinue: onContinue,
            progress: flutterState.progress,
          ),
        ],
      );
    },
  );
}
