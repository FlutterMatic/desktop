import 'package:flutter/material.dart';
import 'package:flutter_installer/components/widgets/rectangle_button.dart';
import 'package:flutter_installer/components/widgets/warning_widget.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class EditorsSettingsSection extends StatefulWidget {
  @override
  _EditorsSettingsSectionState createState() => _EditorsSettingsSectionState();
}

class _EditorsSettingsSectionState extends State<EditorsSettingsSection> {
  late SharedPreferences _pref;

  Future<void> _getDefaultEditor() async {
    _pref = await SharedPreferences.getInstance();
    if (_pref.containsKey('default_editor')) {
      setState(() => defaultEditor = _pref.getString('default_editor'));
    }
  }

  @override
  void initState() {
    _getDefaultEditor();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Default Editor',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        // const SizedBox(height: 15),
        if (defaultEditor == null)
          warningWidget(
              'You have no selected default editor. Choose one so we know what to open your projects with.',
              Assets.warning,
              kYellowColor),
        const SizedBox(height: 15),
        Row(
          children: <Widget>[
            Expanded(
              child: RectangleButton(
                height: 100,
                onPressed: () async {
                  setState(() => defaultEditor = 'code');
                  _pref = await SharedPreferences.getInstance();
                  await _pref.setString('default_editor', 'code');
                },
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: SvgPicture.asset(Assets.vscode),
                          ),
                          Text(
                            'VS Code',
                            style: TextStyle(
                                color: customTheme.textTheme.bodyText1!.color),
                          ),
                        ],
                      ),
                    ),
                    if (defaultEditor == 'code')
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Icon(Icons.check, color: kGreenColor),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RectangleButton(
                height: 100,
                onPressed: () async {
                  setState(() => defaultEditor = 'studio64');
                  _pref = await SharedPreferences.getInstance();
                  await _pref.setString('default_editor', 'studio64');
                },
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: SvgPicture.asset(Assets.androidStudio),
                          ),
                          Text(
                            'Android Studio',
                            style: TextStyle(
                                color: customTheme.textTheme.bodyText1!.color),
                          ),
                        ],
                      ),
                    ),
                    if (defaultEditor == 'studio64')
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Icon(Icons.check, color: kGreenColor),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (Platform.isMacOS) const SizedBox(width: 10),
            if (Platform.isMacOS)
              Expanded(
                child: RectangleButton(
                  height: 100,
                  onPressed: () async {
                    setState(() => defaultEditor = 'xcode');
                    _pref = await SharedPreferences.getInstance();
                    await _pref.setString('default_editor', 'xcode');
                  },
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Column(
                          children: <Widget>[
                            Expanded(child: SvgPicture.asset(Assets.xcode)),
                            Text(
                              'Xcode',
                              style: TextStyle(
                                  color:
                                      customTheme.textTheme.bodyText1!.color),
                            ),
                          ],
                        ),
                      ),
                      if (defaultEditor == 'xcode')
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(Icons.check, color: kGreenColor),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
