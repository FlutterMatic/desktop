// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/app/constants/shared_pref.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/components/widgets/ui/tab_view.dart';
import 'package:fluttermatic/components/widgets/ui/warning_widget.dart';
import 'package:fluttermatic/meta/utils/shared_pref.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabViewTabHeadline(
      title: 'About',
      content: <Widget>[
        informationWidget(
          'FlutterMatic entirely relies on people who contributed to this project. As a way of showing appreciation, we are listing the name of the most active contributors.',
          type: InformationType.green,
        ),
        VSeparators.small(),
        infoWidget(context,
            'This project is completely open-source and can be found on GitHub.'),
        VSeparators.small(),
        informationWidget(
          'Version: ${SharedPref().pref.getString(SPConst.appVersion) ?? 'Unknown app version'} (${SharedPref().pref.getString(SPConst.appBuild)?.toUpperCase() ?? 'Unknown app build'}) \n$osName - $osVersion',
          showIcon: false,
          type: InformationType.info,
        ),
        VSeparators.small(),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            child: const Text('Licenses'),
            onPressed: () {
              showLicensePage(
                context: context,
                applicationIcon: Image.asset(Assets.appLogo),
                applicationName: 'FlutterMatic',
                applicationVersion: appVersion + ' ($appBuild)',
              );
            },
          ),
        ),
      ],
    );
  }
}
