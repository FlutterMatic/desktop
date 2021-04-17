import 'package:flutter/material.dart';
import 'package:flutter_installer/components/title_section.dart';
import 'package:flutter_installer/utils/constants.dart';

Widget installedComponents(Size size) {
  return SizedBox(
    width: size.width > 1000 ? 0.4 * size.width : 0.7 * size.width,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        titleSection('Installed Components', const Icon(Iconsdata.settings),
            () {}, 'Settings'),
        const SizedBox(height: 20),
        installationStatus(
          InstallationStatus.done,
          'Flutter Installed',
          'You will need to have Flutter installed on your machine. This is how your machine will be able to understand the Dart language.',
          () {},
        ),
        installationStatus(
          InstallationStatus.error,
          'Java',
          'Sometimes Flutter will need to have Java installed on your machine to run your app on a physical device or emulator. We recommend you installing Java on your machine.',
          () {},
        ),
        installationStatus(
          InstallationStatus.done,
          'Visual Studio Code',
          'We recommend using Visual Studio Code for developing Flutter apps. It is lightweight which means uses less space and memory.',
          () {},
        ),
        installationStatus(
          InstallationStatus.warning,
          'Android Studio',
          'If you need to use an Android Emulator, you will need to have Android Studio installed on your machine with all of it\'s components.',
          () {},
        ),
      ],
    ),
  );
}
