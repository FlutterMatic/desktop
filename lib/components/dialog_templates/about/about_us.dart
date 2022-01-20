// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/components/dialog_templates/about/sections/about.dart';
import 'package:fluttermatic/components/dialog_templates/about/sections/changelog.dart';
import 'package:fluttermatic/components/dialog_templates/about/sections/contributors.dart';
import 'package:fluttermatic/components/dialog_templates/about/sections/report.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/core/libraries/widgets.dart';

class AboutUsDialog extends StatelessWidget {
  const AboutUsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      width: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          DialogHeader(title: 'About'),
          TabViewWidget(
            tabs: <TabViewObject>[
              TabViewObject('About', AboutSection()),
              TabViewObject('Contributors', ContributorsAboutSection()),
              TabViewObject('Changelog', ChangelogAboutSection()),
              TabViewObject('Report', ReportAboutSection()),
            ],
          ),
        ],
      ),
    );
  }
}
