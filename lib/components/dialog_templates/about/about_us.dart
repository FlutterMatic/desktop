import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/about/sections/about.dart';
import 'package:flutter_installer/components/dialog_templates/about/sections/changelog.dart';
import 'package:flutter_installer/components/dialog_templates/about/sections/contributers.dart';
import 'package:flutter_installer/components/dialog_templates/dialog_header.dart';
import 'package:flutter_installer/components/widgets/ui/dialog_template.dart';
import 'package:flutter_installer/components/widgets/ui/tab_view.dart';

class AboutUsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      width: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DialogHeader(title: 'About'),
          const SizedBox(height: 10),
          TabViewWidget(
            tabNames: ['About', 'Contributers', 'Changelog'],
            tabItems: [
              // About
              AboutSection(),
              // Contributers
              ContributersAboutSection(),
              // Changelog
              ChangelogAboutSection(),
            ],
          ),
        ],
      ),
    );
  }
}
