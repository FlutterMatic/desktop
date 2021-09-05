import 'package:flutter/material.dart';
import 'package:manager/components/dialog_templates/about/sections/about.dart';
import 'package:manager/components/dialog_templates/about/sections/changelog.dart';
import 'package:manager/components/dialog_templates/about/sections/contributors.dart';
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/core/libraries/widgets.dart';

class AboutUsDialog extends StatelessWidget {
  const AboutUsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      width: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const DialogHeader(title: 'About'),
          const TabViewWidget(
            tabs: <TabViewObject>[
              TabViewObject('About', AboutSection()),
              TabViewObject('Contributors', ContributorsAboutSection()),
              TabViewObject('Changelog', ChangelogAboutSection()),
            ],
          ),
        ],
      ),
    );
  }
}
