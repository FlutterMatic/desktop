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
  //Utils
  bool _loading = false;

  @override
  void dispose() {
    _loading = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      width: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const DialogHeader(title: 'Settings'),
          const SizedBox(height: 20),
          TabViewWidget(
            defaultPage: widget.goToPage,
            tabs: <TabViewObject>[
              TabViewObject('Theme', ThemeSettingsSection()),
              TabViewObject('Projects', ProjectsSettingsSection()),
              TabViewObject('Editors', EditorsSettingsSection()),
              TabViewObject('GitHub', GitHubSettingsSection()),
              TabViewObject('Troubleshoot', TroubleShootSettingsSection()),
              TabViewObject('Discover', DiscoverSettingsSection()),
            ],
          ),
          RectangleButton(
            loading: _loading,
            onPressed: () => Navigator.pop(context),
            width: double.infinity,
            color: Colors.blueGrey,
            splashColor: Colors.blueGrey.withOpacity(0.5),
            focusColor: Colors.blueGrey.withOpacity(0.5),
            hoverColor: Colors.grey.withOpacity(0.5),
            highlightColor: Colors.blueGrey.withOpacity(0.5),
            child: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }
}
