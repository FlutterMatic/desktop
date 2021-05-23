import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/dialog_header.dart';
import 'package:flutter_installer/components/dialog_templates/settings/sections/discover.dart';
import 'package:flutter_installer/components/dialog_templates/settings/sections/editors.dart';
import 'package:flutter_installer/components/dialog_templates/settings/sections/github.dart';
import 'package:flutter_installer/components/dialog_templates/settings/sections/projects.dart';
import 'package:flutter_installer/components/dialog_templates/settings/sections/theme.dart';
import 'package:flutter_installer/components/dialog_templates/settings/sections/troubleshoot.dart';
import 'package:flutter_installer/components/widgets/ui/dialog_template.dart';
import 'package:flutter_installer/components/widgets/buttons/rectangle_button.dart';
import 'package:flutter_installer/components/widgets/ui/tab_view.dart';

class SettingDialog extends StatefulWidget {
  final String? goToPage;

  SettingDialog({this.goToPage});

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
          DialogHeader(title: 'Settings'),
          const SizedBox(height: 20),
          TabViewWidget(
            defaultPage: widget.goToPage,
            tabNames: [
              'Theme',
              'Projects',
              'Editors',
              'GitHub',
              'Troublshoot',
              'Discover',
            ],
            tabItems: [
              //Themes
              ThemeSettingsSection(),
              //Projects
              ProjectsSettingsSection(),
              //Editors
              EditorsSettingsSection(),
              //GitHub
              GitHubSettingsSection(),
              //Troubleshoot
              TroubleShootSettingsSection(),
              //Discover
              DiscoverSettingsSection(),
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