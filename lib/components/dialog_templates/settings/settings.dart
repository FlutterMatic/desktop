// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/dialog_templates/settings/sections/discover.dart';
import 'package:fluttermatic/components/dialog_templates/settings/sections/editors.dart';
import 'package:fluttermatic/components/dialog_templates/settings/sections/github.dart';
import 'package:fluttermatic/components/dialog_templates/settings/sections/overview.dart';
import 'package:fluttermatic/components/dialog_templates/settings/sections/projects.dart';
import 'package:fluttermatic/components/dialog_templates/settings/sections/troubleshoot.dart';
import 'package:fluttermatic/components/dialog_templates/settings/sections/updates.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/tab_view.dart';

class SettingDialog extends StatelessWidget {
  final SettingsPage? goToPage;

  const SettingDialog({Key? key, this.goToPage}) : super(key: key);

  String? _getTitle() {
    switch (goToPage) {
      case SettingsPage.overview:
        return 'Overview';
      case SettingsPage.projects:
        return 'Projects';
      case SettingsPage.editors:
        return 'Editors';
      case SettingsPage.github:
        return 'GitHub';
      case SettingsPage.troubleshoot:
        return 'Troubleshoot';
      case SettingsPage.discover:
        return 'Discover';
      case SettingsPage.updates:
        return 'Updates';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      width: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const DialogHeader(title: 'Settings'),
          TabViewWidget(
            defaultPage: _getTitle(),
            tabs: const <TabViewObject>[
              TabViewObject('Overview', OverviewSettingsSection()),
              TabViewObject('Projects', ProjectsSettingsSection()),
              TabViewObject('Editors', EditorsSettingsSection()),
              TabViewObject('GitHub', GitHubSettingsSection()),
              TabViewObject('Troubleshoot', TroubleShootSettingsSection()),
              TabViewObject('Discover', DiscoverSettingsSection()),
              TabViewObject('Updates', UpdatesSettingsSection()),
            ],
          ),
        ],
      ),
    );
  }
}

enum SettingsPage {
  overview,
  projects,
  editors,
  github,
  troubleshoot,
  discover,
  updates,
}
