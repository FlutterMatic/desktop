import 'package:flutter/material.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/ui/info_widget.dart';
import 'package:manager/core/libraries/checks.dart';
import 'package:manager/core/libraries/components.dart';
import 'package:provider/provider.dart';

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
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: (flutterNotifier.progress == Progress.started ||
                  flutterNotifier.progress == Progress.checking)
              ? hLoadingIndicator(context: context)
              : flutterNotifier.progress == Progress.downloading
                  ? const CustomProgressIndicator()
                  : (flutterNotifier.progress == Progress.extracting)
                      ? hLoadingIndicator(context: context)
                      : flutterNotifier.progress == Progress.done
                          ? welcomeToolInstalled(
                              context,
                              title: 'Flutter Installed',
                              message:
                                  'Flutter was installed successfully on your device. Continue to the next step.',
                            )
                          : flutterNotifier.progress == Progress.none
                              ? infoWidget(context, 'We will check if you have Flutter installed or not and install it for you if you don\'t.')
                              : hLoadingIndicator(context: context),
        ),
        VSeparators.small(),
        WelcomeButton(
          onInstall: onInstall,
          onContinue: onContinue,
          progress: flutterNotifier.progress,
        ),
      ],
    );
  });
}
