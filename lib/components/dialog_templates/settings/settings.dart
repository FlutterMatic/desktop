import 'package:flutter/material.dart';
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/components/dialog_templates/settings/sections/discover.dart';
import 'package:manager/components/dialog_templates/settings/sections/editors.dart';
import 'package:manager/components/dialog_templates/settings/sections/github.dart';
import 'package:manager/components/dialog_templates/settings/sections/projects.dart';
import 'package:manager/components/dialog_templates/settings/sections/theme.dart';
import 'package:manager/components/dialog_templates/settings/sections/troubleshoot.dart';
import 'package:manager/core/libraries/widgets.dart';

class SettingDialog extends StatefulWidget {
  final String? goToPage;

  const SettingDialog({Key? key, this.goToPage}) : super(key: key);

  @override
  _SettingDialogState createState() => _SettingDialogState();
}

class _SettingDialogState extends State<SettingDialog> {
  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      width: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const DialogHeader(title: 'Settings'),
          TabViewWidget(
            defaultPage: widget.goToPage,
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
