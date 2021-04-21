import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/general/install_fluter.dart';
import 'package:flutter_installer/components/dialog_templates/settings/dependencies_settings.dart';
import 'package:flutter_installer/components/widgets/title_section.dart';
import 'package:flutter_installer/utils/constants.dart';

Widget installedComponents(BuildContext context) {
  ThemeData customTheme = Theme.of(context);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      titleSection('Flutter SDK & Dependencies',
          Icon(Icons.settings, color: customTheme.iconTheme.color), () {
        showDialog(
          context: context,
          builder: (_) => DependenciesSettings(),
        );
      }, context: context),
      const SizedBox(height: 25),
      installationStatus(
        flutterInstalled ? InstallationStatus.done : InstallationStatus.error,
        flutterInstalled ? 'Flutter Installed' : 'Flutter Not Installed',
        'You will need to have Flutter installed on your machine. This is how your machine will be able to understand the Dart language.',
        onDownload: () {
          showDialog(
            context: context,
            builder: (_) => InstallFlutterDialog(),
          );
        },
        tooltip: 'Flutter',
        context: context,
      ),
      installationStatus(
        javaInstalled ? InstallationStatus.done : InstallationStatus.error,
        javaInstalled ? 'Java Installed' : 'Java Not Installed',
        'Sometimes Flutter will need to have Java installed on your machine to run your app on a physical device or emulator. We recommend you installing Java on your machine.',
        onDownload: () {},
        tooltip: 'Java',
        context: context,
      ),
      installationStatus(
        vscInstalled ? InstallationStatus.done : InstallationStatus.error,
        vscInstalled ? 'VSCode Installed' : 'VSCode Not installed',
        'We recommend using Visual Studio Code for developing Flutter apps. It is lightweight which means uses less space and memory.',
        onDownload: () {},
        tooltip: 'VSCode',
        context: context,
      ),
      installationStatus(
        studioInstalled ? InstallationStatus.done : InstallationStatus.error,
        studioInstalled
            ? 'Android Studio Installed'
            : 'Android Studio Not Installed',
        'If you need to use an Android Emulator, you will need to have Android Studio installed on your machine with all of it\'s components.',
        onDownload: () {},
        tooltip: 'Android Studio',
        context: context,
      ),
    ],
  );
}
