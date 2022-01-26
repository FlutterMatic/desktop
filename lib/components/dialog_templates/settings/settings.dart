// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/dialog_templates/settings/sections/discover.dart';
import 'package:fluttermatic/components/dialog_templates/settings/sections/editors.dart';
import 'package:fluttermatic/components/dialog_templates/settings/sections/github.dart';
import 'package:fluttermatic/components/dialog_templates/settings/sections/projects.dart';
import 'package:fluttermatic/components/dialog_templates/settings/sections/theme.dart';
import 'package:fluttermatic/components/dialog_templates/settings/sections/troubleshoot.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/tab_view.dart';

class SettingDialog extends StatelessWidget {
  final String? goToPage;

  const SettingDialog({Key? key, this.goToPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      width: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const DialogHeader(title: 'Settings'),
          TabViewWidget(
            defaultPage: goToPage,
            tabs: const <TabViewObject>[
              TabViewObject('Theme', ThemeSettingsSection()),
              TabViewObject('Projects', ProjectsSettingsSection()),
              TabViewObject('Editors', EditorsSettingsSection()),
              TabViewObject('GitHub', GitHubSettingsSection()),
              TabViewObject('Troubleshoot', TroubleShootSettingsSection()),
              TabViewObject('Discover', DiscoverSettingsSection()),
            ],
          ),
        ],
      ),
    );
  }
}
