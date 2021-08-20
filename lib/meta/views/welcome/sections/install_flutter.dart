import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: (flutterNotifier.progress == Progress.STARTED ||
                  flutterNotifier.progress == Progress.CHECKING)
              ? Column(
                  children: <Widget>[
                    hLoadingIndicator(
                      context: context,
                      message: 'Checking for flutter',
                    ),
                    const Text('Checking for flutter'),
                  ],
                )
              : (flutterNotifier.progress == Progress.DOWNLOADING ||
                      flutterNotifier.progress == Progress.FAILED)
                  ? CustomProgressIndicator(
                      disabled: (flutterNotifier.progress !=
                              Progress.CHECKING &&
                          flutterNotifier.progress != Progress.DOWNLOADING &&
                          flutterNotifier.progress != Progress.STARTED),
                      progress: flutterNotifier.progress,
                      toolName: 'Flutter',
                      onCancel: onCancel,
                      message: 'Downloading Flutter',
                    )
                  : (flutterNotifier.progress == Progress.EXTRACTING)
                      // ? CustomProgressIndicator(
                      //     disabled: true,
                      //     progress: flutterNotifier.progress,
                      //     toolName: 'Flutter',
                      //     onCancel: onCancel,
                      //   )
                      ? Tooltip(message: 'Extracting flutter',
                        child: Lottie.asset(
                            Assets.extracting,
                            height: 100,
                          ),
                      )
                      : flutterNotifier.progress == Progress.DONE
                          ? welcomeToolInstalled(
                              context,
                              title: 'Flutter Installed',
                              message:
                                  'Flutter was installed successfully on your machine. Continue to the next step.',
                            )
                          : flutterNotifier.progress == Progress.NONE
                              ? const SizedBox.shrink()
                              : hLoadingIndicator(
                                  context: context,
                                ),
        ),
        if (flutterNotifier.progress == Progress.DONE)
          const SizedBox(height: 30),
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
