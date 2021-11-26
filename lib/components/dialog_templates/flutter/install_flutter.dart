// 🎯 Dart imports:
import 'dart:io' show Platform;

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:manager/core/libraries/components.dart';
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/core/libraries/widgets.dart';

class FlutterRequirementsDialog extends StatelessWidget {
  const FlutterRequirementsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const DialogHeader(title: 'Install Flutter'),
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
                  VSeparators.xSmall(),
                  SvgPicture.asset(Assets.warn),
                  VSeparators.normal(),
                  const Text(
                    'Unknown Device',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  VSeparators.small(),
                  const Text(
                    'We couldn\'t for some reason know what your device is so that we can download the proper Flutter resources. Please report this issue by going to Settings > GitHub > Create Issue.',
                    textAlign: TextAlign.center,
                  ),
                  VSeparators.xSmall(),
                ],
              ),
            ),
          VSeparators.small(),
          infoWidget(context,
              'Please be aware that all necessary components will be installed with Flutter such as git if you don\'t already have it installed.'),
          VSeparators.small(),
          RectangleButton(
            width: double.infinity,
            color: Colors.blueGrey,
            splashColor: Colors.blueGrey.withOpacity(0.5),
            focusColor: Colors.blueGrey.withOpacity(0.5),
            hoverColor: Colors.grey.withOpacity(0.5),
            highlightColor: Colors.blueGrey.withOpacity(0.5),
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
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
      VSeparators.small(),
      const BulletPoint('1.64 GB (does not include disk space for IDE/tools).'),
      VSeparators.normal(),
      const Text(
        'Tools',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      VSeparators.small(),
      const BulletPoint('Flutter depends on these tools being available in your environment.'),
      VSeparators.small(),
      const BulletPoint('Windows PowerShell 5.0 or newer (this is pre-installed with Windows)', 2),
      VSeparators.small(),
      const BulletPoint('Git for Windows 2.x, with the Use Git from the Windows Command Prompt option.', 2),
      VSeparators.normal(),
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
      VSeparators.small(),
      const BulletPoint('2.8 GB (does not include disk space for IDE/tools).'),
      VSeparators.normal(),
      const Text(
        'Tools',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      VSeparators.small(),
      const BulletPoint(
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
      VSeparators.small(),
      const BulletPoint('600 MB (does not include disk space for IDE/tools).'),
      VSeparators.normal(),
      const Text(
        'Tools',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      VSeparators.small(),
      const BulletPoint('Flutter depends on these command-line tools being available in your environment.'),
      VSeparators.small(),
      const BulletPoint('bash, curl, file, git 2.x, mkdir, rm, unzip, which, xz-utils and zip', 2),
      VSeparators.normal(),
      const Text(
        'Shared libraries',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      VSeparators.small(),
      const BulletPoint('"Flutter test" command depends on this library being available in your environment.'),
      VSeparators.small(),
      const BulletPoint(
          '"libGLU.so.1" - provided by mesa packages such as "libglu1-mesa" on Ubuntu/Debian and "mesa-libGLU" on Fedora.',
          2),
    ],
  );
}
