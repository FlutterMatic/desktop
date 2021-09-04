import 'package:flutter/material.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/checks.dart';
import 'package:manager/core/libraries/components.dart';
import 'package:provider/provider.dart';

Widget installFlutter(
  BuildContext context, {
  required VoidCallback onInstall,
  required VoidCallback onCancel,
  VoidCallback? onContinue,
  // required Progress progress,
}) {
  return Consumer<FlutterNotifier>(
      builder: (BuildContext context, FlutterNotifier flutterNotifier, _) {
    return Column(
      children: <Widget>[
        welcomeHeaderTitle(
          Assets.flutter,
          'Install Flutter',
          'You will need to install Flutter in your machine to start using Flutter.',
        ),
        VSeparators.xLarge(),
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: (flutterNotifier.progress == Progress.started ||
                  flutterNotifier.progress == Progress.checking)
              ? Column(
                  children: <Widget>[
                    hLoadingIndicator(
                      context: context,
                    ),
                    const Text('Checking for flutter'),
                  ],
                )
              : (flutterNotifier.progress == Progress.downloading ||
                      flutterNotifier.progress == Progress.failed)
                  ? CustomProgressIndicator(
                      disabled: (flutterNotifier.progress !=
                              Progress.checking &&
                          flutterNotifier.progress != Progress.downloading &&
                          flutterNotifier.progress != Progress.started),
                      progress: flutterNotifier.progress,
                      toolName: 'Flutter',
                      onCancel: onCancel,
                      message: 'Downloading Flutter',
                    )
                  : (flutterNotifier.progress == Progress.extracting)
                      // ? CustomProgressIndicator(
                      //     disabled: true,
                      //     progress: flutterNotifier.progress,
                      //     toolName: 'Flutter',
                      //     onCancel: onCancel,
                      //   )
                      ? Column(
                          children: <Widget>[
                            hLoadingIndicator(
                              context: context,
                            ),
                            const Text('Extracting Flutter'),
                          ],
                        )
                      : flutterNotifier.progress == Progress.done
                          ? welcomeToolInstalled(
                              context,
                              title: 'Flutter Installed',
                              message:
                                  'Flutter was installed successfully on your machine. Continue to the next step.',
                            )
                          : flutterNotifier.progress == Progress.none
                              ? const SizedBox.shrink()
                              : hLoadingIndicator(
                                  context: context,
                                ),
        ),
        VSeparators.xLarge(),
        WelcomeButton(
          onContinue: onContinue,
          onInstall: onInstall,
          progress: flutterNotifier.progress,
          toolName: 'Flutter',
        ),
      ],
    );
  });
}
