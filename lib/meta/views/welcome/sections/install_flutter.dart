// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/libraries/checks.dart';
import 'package:fluttermatic/core/libraries/components.dart';
import 'package:fluttermatic/core/libraries/constants.dart';

Widget installFlutter(
  BuildContext context, {
  VoidCallback? onContinue,
  required VoidCallback onInstall,
}) {
  return Consumer<FlutterNotifier>(
      builder: (BuildContext context, FlutterNotifier flutterNotifier, _) {
    return Column(
      children: <Widget>[
        welcomeHeaderTitle(
          Assets.flutter,
          'Install Flutter',
          'You will need to install Flutter in your device to start using Flutter.',
        ),
        VSeparators.xLarge(),
        Builder(
          builder: (_) {
            if (flutterNotifier.progress == Progress.started ||
                flutterNotifier.progress == Progress.checking) {
              return hLoadingIndicator(context: context);
            } else if (flutterNotifier.progress == Progress.downloading) {
              return const CustomProgressIndicator();
            } else if (flutterNotifier.progress == Progress.extracting) {
              return hLoadingIndicator(context: context);
            } else if (flutterNotifier.progress == Progress.none) {
              return infoWidget(context,
                  'We will check if you have Flutter installed or not and install it for you if you don\'t.');
            } else if (flutterNotifier.progress == Progress.done) {
              return welcomeToolInstalled(
                context,
                title:
                    'Flutter Installed - v${flutterNotifier.flutterVersion ?? 'Unknown'}',
                message:
                    'Flutter was installed successfully on your device. Continue to the next step.',
              );
            } else {
              return hLoadingIndicator(context: context);
            }
          },
        ),
        VSeparators.normal(),
        WelcomeButton(
          onInstall: onInstall,
          onContinue: onContinue,
          progress: flutterNotifier.progress,
        ),
      ],
    );
  });
}
