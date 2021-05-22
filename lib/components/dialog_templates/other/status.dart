import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/dialog_header.dart';
import 'package:flutter_installer/components/dialog_templates/flutter/install_flutter.dart';
import 'package:flutter_installer/components/widgets/ui/dialog_template.dart';
import 'package:flutter_installer/components/widgets/ui/info_widget.dart';
import 'package:flutter_installer/components/widgets/buttons/rectangle_button.dart';
import 'package:flutter_installer/components/widgets/ui/title_section.dart';
import 'package:flutter_installer/components/widgets/ui/warning_widget.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class StatusDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          DialogHeader(title: 'Status'),
          const SizedBox(height: 25),
          installationStatus(
            flutterInstalled
                ? InstallationStatus.done
                : InstallationStatus.error,
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
          const SizedBox(height: 20),
          installationStatus(
            javaInstalled ? InstallationStatus.done : InstallationStatus.error,
            javaInstalled ? 'Java Installed' : 'Java Not Installed',
            'Sometimes Flutter will need to have Java installed on your machine to run your app on a physical device or emulator. We recommend you installing Java on your machine.',
            onDownload: () {
              launch('https://docs.oracle.com/en/java/');
            },
            tooltip: 'Java',
            context: context,
          ),
          const SizedBox(height: 20),
          installationStatus(
            vscInstalled ? InstallationStatus.done : InstallationStatus.error,
            vscInstalled ? 'VS Code Installed' : 'VS Code Not installed',
            'We recommend using Visual Studio Code for developing Flutter apps. It is lightweight which means uses less space and memory.',
            onDownload: () {
              launch('urlString');
            },
            tooltip: 'VS Code',
            context: context,
          ),
          const SizedBox(height: 20),
          installationStatus(
            studioInstalled
                ? InstallationStatus.done
                : InstallationStatus.error,
            studioInstalled
                ? 'Android Studio Installed'
                : 'Android Studio Not Installed',
            'If you need to use an Android Emulator, you will need to have Android Studio installed on your machine with all of it\'s components.',
            onDownload: () {
              launch('https://developer.android.com/studio/');
            },
            tooltip: 'Android Studio',
            context: context,
          ),
          const SizedBox(height: 15),
          if (!studioInstalled ||
              !vscInstalled ||
              !javaInstalled ||
              !flutterInstalled)
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: warningWidget(
                'We recommend installing everything that is necessary to have the best Flutter environment setup.',
                Assets.error,
                kRedColor,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: infoWidget(
                  'Everything seems to be setup correctly! If there are any issues you find with this app, please report it. Go to Settings > GitHub > Create Issue.'),
            ),
          RectangleButton(
            onPressed: () {
              Navigator.pop(context);
            },
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
