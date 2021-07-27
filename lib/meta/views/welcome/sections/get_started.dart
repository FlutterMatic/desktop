import 'package:flutter/material.dart';
import 'package:manager/meta/views/welcome/components/button.dart';
import 'package:manager/meta/views/welcome/components/header_title.dart';

Widget welcomeGettingStarted(Function onContinue) {
  return Column(
    children: [
      welcomeHeaderTitle(
        'assets/images/logos/flutter.svg',
        'Install Flutter',
        'Welcome to the Flutter installer. You will be guided through the steps necessary to setup and install Flutter in your computer.',
        iconHeight: 50,
      ),
      const SizedBox(height: 50),
      welcomeButton('Continue', onContinue),
    ],
  );
}
