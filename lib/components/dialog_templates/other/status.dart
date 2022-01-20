// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/core/libraries/widgets.dart';

class StatusDialog extends StatelessWidget {
  const StatusDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          const DialogHeader(title: 'Status'),
          // TODO: Show the Flutter installed status.
          // installationStatus(
          //   flutterInstalled
          //       ? InstallationStatus.done
          //       : InstallationStatus.error,
          //   flutterInstalled ? 'Flutter Installed' : 'Flutter Not Installed',
          //   'You will need to have Flutter installed on your device. This is how your device will be able to understand the Dart language.',
          //   onDownload: () {
          //     showDialog(
          //       context: context,
          //       builder: (_) => InstallFlutterDialog(),
          //     );
          //   },
          //   tooltip: 'Flutter',
          //   context: context,
          // ),
          VSeparators.large(),
          // TODO: Show the Java installed status.
          // installationStatus(
          //   javaInstalled ? InstallationStatus.done : InstallationStatus.error,
          //   javaInstalled ? 'Java Installed' : 'Java Not Installed',
          //   'Sometimes Flutter will need to have Java installed on your device to run your app on a physical device or emulator. We recommend you installing Java on your device.',
          //   onDownload: () {
          //     launch('https://docs.oracle.com/en/java/');
          //   },
          //   tooltip: 'Java',
          //   context: context,
          // ),
          VSeparators.large(),
          // TODO: Show the Visual Studio code installed.
          // installationStatus(
          //   vscInstalled ? InstallationStatus.done : InstallationStatus.error,
          //   vscInstalled ? 'VS Code Installed' : 'VS Code Not installed',
          //   'We recommend using Visual Studio Code for developing Flutter apps. It is lightweight which means uses less space and memory.',
          //   onDownload: () {
          //     launch('https://code.visualstudio.com/Download');
          //   },
          //   tooltip: 'VS Code',
          //   context: context,
          // ),
          VSeparators.large(),
          // TODO: Show the Android Studio installed status.
          // installationStatus(
          //   studioInstalled
          //       ? InstallationStatus.done
          //       : InstallationStatus.error,
          //   studioInstalled
          //       ? 'Android Studio Installed'
          //       : 'Android Studio Not Installed',
          //   'If you need to use an Android Emulator, you will need to have Android Studio installed on your device with all of it\'s components.',
          //   onDownload: () {
          //     launch('https://developer.android.com/studio/');
          //   },
          //   tooltip: 'Android Studio',
          //   context: context,
          // ),
          VSeparators.normal(),
          // TODO: Show the below widget if one or more of the tools is not installed
          // if (_missingInstalledTools)
          //   Padding(
          //     padding: const EdgeInsets.only(bottom: 15),
          //     child: warningWidget(
          //       'We recommend installing everything that is necessary to have the best Flutter environment setup.',
          //       Assets.error,
          //       kRedColor,
          //     ),
          //   )
          // else
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: infoWidget(context,
                'Everything seems to be setup correctly! If there are any issues you find with this app, please report it. Go to Settings > GitHub > Create Issue.'),
          ),
          RectangleButton(
            onPressed: () => Navigator.pop(context),
            width: double.infinity,
            child: Text(
              'Close',
              style: TextStyle(color: customTheme.textTheme.bodyText1!.color),
            ),
          ),
        ],
      ),
    );
  }
}
