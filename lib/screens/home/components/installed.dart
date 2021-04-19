import 'package:flutter/material.dart';
import 'package:flutter_installer/components/title_section.dart';
import 'package:flutter_installer/screens/home/components/controls.dart';
import 'package:flutter_installer/utils/constants.dart';

Widget installedComponents(BuildContext context) {
  ThemeData customTheme = Theme.of(context);
  return SizedBox(
    width: 500,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        titleSection(
          'Flutter SDK and dependencies',
          Icon(
            Iconsdata.settings,
            color: customTheme.iconTheme.color,
          ),
          () {},
          'Settings',
          context: context,
        ),
        const SizedBox(height: 20),
        installationStatus(
          flutterExist ? InstallationStatus.done : InstallationStatus.error,
          flutterExist
              ? 'Flutter Installed - v$flutterVersion'
              : 'Flutter Not Installed',
          '''
You will need to have Flutter installed on your machine. This is how your machine will be able to understand the Dart language.''',
          onDownload: () {},
          tooltip: 'Flutter',
          hoverColor: customTheme.focusColor,
        ),
        installationStatus(
          javaInstalled ? InstallationStatus.done : InstallationStatus.error,
          javaInstalled
              ? 'Java Installed - v$javaVersion'
              : 'Java Not Installed',
          '''
Sometimes Flutter will need to have Java installed on your machine to run your app on a physical device or emulator. We recommend you installing Java on your machine.''',
          onDownload: () {},
          tooltip: 'Java',
          hoverColor: customTheme.focusColor,
        ),
        installationStatus(
          vscInstalled ? InstallationStatus.done : InstallationStatus.error,
          vscInstalled
              ? 'Visual Studio Code - v$codeVersion'
              : 'Visual Studio Code not installed',
          '''
We recommend using Visual Studio Code for developing Flutter apps. It is lightweight which means uses less space and memory.''',
          onDownload: () {},
          tooltip: 'VSCode',
          hoverColor: customTheme.focusColor,
        ),
        installationStatus(
          studioInstalled ? InstallationStatus.done : InstallationStatus.error,
          studioInstalled
              ? 'Android Studio Installed'
              : 'Android Studio Not Installed',
          '''
If you need to use an Android Emulator, you will need to have Android Studio installed on your machine with all of it\'s components.''',
          onDownload: () {},
          tooltip: 'Android studio',
          hoverColor: customTheme.focusColor,
        ),
        examplesTile(context),
      ],
    ),
  );
}
