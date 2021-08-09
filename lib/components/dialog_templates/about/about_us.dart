import 'package:flutter/material.dart';
import 'package:manager/components/dialog_templates/about/sections/about.dart';
import 'package:manager/components/dialog_templates/about/sections/changelog.dart';
import 'package:manager/components/dialog_templates/about/sections/contributors.dart';
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/components/widgets/ui/dialog_template.dart';
import 'package:manager/components/widgets/ui/tab_view.dart';

class AboutUsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      width: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DialogHeader(title: 'About'),
          const SizedBox(height: 10),
          TabViewWidget(
            tabNames: const <String>['About', 'Contributors', 'Changelog'],
            tabItems: <Widget>[
              // About
              AboutSection(),
              // Contributors
              ContributorsAboutSection(),
              // Changelog
              ChangelogAboutSection(),
            ],
          ),
        ],
      ),
    );
  }
}
