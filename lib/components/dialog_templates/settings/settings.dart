import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/dialog_header.dart';
import 'package:flutter_installer/components/dialog_templates/settings/sections/discover.dart';
import 'package:flutter_installer/components/dialog_templates/settings/sections/editors.dart';
import 'package:flutter_installer/components/dialog_templates/settings/sections/github.dart';
import 'package:flutter_installer/components/dialog_templates/settings/sections/projects.dart';
import 'package:flutter_installer/components/dialog_templates/settings/sections/theme.dart';
import 'package:flutter_installer/components/dialog_templates/settings/sections/troubleshoot.dart';
import 'package:flutter_installer/components/widgets/dialog_template.dart';
import 'package:flutter_installer/components/widgets/rectangle_button.dart';
import 'package:flutter_installer/services/themes.dart';

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

class TabViewWidget extends StatefulWidget {
  final String? defaultPage;
  final List<String> tabNames;
  final List<Widget> tabItems;

  TabViewWidget(
      {required this.tabNames, required this.tabItems, this.defaultPage})
      : assert(tabNames.length == tabItems.length,
            'Both item lengths must be the same'),
        assert(tabNames.isNotEmpty && tabItems.isNotEmpty,
            'Item list cannot be empty');

  @override
  _TabViewWidgetState createState() => _TabViewWidgetState();
}

int _index = 0;

class _TabViewWidgetState extends State<TabViewWidget> {
  @override
  void initState() {
    if (widget.defaultPage != null &&
        widget.tabNames.contains(widget.defaultPage)) {
      setState(() => _index = widget.tabNames.indexOf(widget.defaultPage!));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _itemsHeader = [];
    _itemsHeader.clear();
    for (var i = 0; i < widget.tabNames.length; i++) {
      _itemsHeader.add(_tabHeaderWidget(widget.tabNames[i],
          () => setState(() => _index = i), _index == i, context, i == _index));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _itemsHeader),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 310,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: widget.tabItems[_index],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabHeaderWidget(String name, Function() onPressed, bool selected,
      BuildContext context, bool current) {
    ThemeData customTheme = Theme.of(context);
    return RectangleButton(
      width: 130,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      color: selected
          ? currentTheme.isDarkTheme
              ? null
              : Colors.grey.withOpacity(0.3)
          : Colors.transparent,
      padding: const EdgeInsets.all(10),
      onPressed: onPressed,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          name,
          style: TextStyle(
              color: customTheme.textTheme.bodyText1!.color!
                  .withOpacity(selected ? 1 : .4)),
        ),
      ),
    );
  }
}
