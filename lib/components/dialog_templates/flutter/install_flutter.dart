import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/components/widgets/buttons/rectangle_button.dart';
import 'package:manager/components/widgets/ui/bullet_point.dart';
import 'dart:io' show Platform;

import 'package:manager/components/widgets/ui/dialog_template.dart';
import 'package:manager/components/widgets/ui/info_widget.dart';
import 'package:manager/components/widgets/ui/round_container.dart';

class InstallFlutterDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const DialogHeader(title: 'Install Flutter'),
          const SizedBox(height: 20),
          if (Platform.isWindows)
            _windowsTemplate()
          else if (Platform.isMacOS)
            _macOSTemplate()
          else if (Platform.isLinux)
            _linuxTemplate()
          else
            RoundContainer(
              color: customTheme.focusColor,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 5),
                  SvgPicture.asset(Assets.warn),
                  const SizedBox(height: 15),
                  const Text(
                    'Unknown Device',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'We couldn\'t for some reason know what your device is so that we can download the proper Flutter resources. Please report this issue by going to Settings > GitHub > Create Issue.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          const SizedBox(height: 10),
          infoWidget(
              'Please be aware that all necessary components will be installed with Flutter such as git if you don\'t already have it installed.'),
          const SizedBox(height: 10),
          RectangleButton(
            width: double.infinity,
            color: Colors.blueGrey,
            splashColor: Colors.blueGrey.withOpacity(0.5),
            focusColor: Colors.blueGrey.withOpacity(0.5),
            hoverColor: Colors.grey.withOpacity(0.5),
            highlightColor: Colors.blueGrey.withOpacity(0.5),
            onPressed: () {},
            child: const Text('Install Flutter'),
          ),
        ],
      ),
    );
  }
}

//Windows Template
Widget _windowsTemplate() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      const Text(
        'Disk Space',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 10),
      BulletPoint('1.64 GB (does not include disk space for IDE/tools).'),
      const SizedBox(height: 15),
      const Text(
        'Tools',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 10),
      BulletPoint(
          'Flutter depends on these tools being available in your environment.'),
      const SizedBox(height: 10),
      BulletPoint(
          'Windows PowerShell 5.0 or newer (this is pre-installed with Windows 10)',
          2),
      const SizedBox(height: 10),
      BulletPoint(
          'Git for Windows 2.x, with the Use Git from the Windows Command Prompt option.',
          2),
      const SizedBox(height: 15),
      const Text(
          'If Git for Windows is already installed, make sure you can run git commands from the command prompt or PowerShell.'),
    ],
  );
}

//MacOS Template
Widget _macOSTemplate() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      const Text(
        'Disk Space',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 10),
      BulletPoint('2.8 GB (does not include disk space for IDE/tools).'),
      const SizedBox(height: 15),
      const Text(
        'Tools',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 10),
      BulletPoint(
          'Flutter uses git for installation and upgrade. We recommend installing Xcode, which includes git, but you can also install git separately.'),
    ],
  );
}

//Linux Template
Widget _linuxTemplate() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      const Text(
        'Disk Space',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 10),
      BulletPoint('600 MB (does not include disk space for IDE/tools).'),
      const SizedBox(height: 15),
      const Text(
        'Tools',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 10),
      BulletPoint(
          'Flutter depends on these command-line tools being available in your environment.'),
      const SizedBox(height: 10),
      BulletPoint(
          'bash, curl, file, git 2.x, mkdir, rm, unzip, which, xz-utils and zip',
          2),
      const SizedBox(height: 15),
      const Text(
        'Shared libraries',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 10),
      BulletPoint(
          '"Flutter test" command depends on this library being available in your environment.'),
      const SizedBox(height: 10),
      BulletPoint(
          '"libGLU.so.1" - provided by mesa packages such as "libglu1-mesa" on Ubuntu/Debian and "mesa-libGLU" on Fedora.',
          2),
    ],
  );
}
