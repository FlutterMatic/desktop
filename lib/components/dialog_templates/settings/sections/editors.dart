import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class EditorsSettingsSection extends StatefulWidget {
  @override
  _EditorsSettingsSectionState createState() => _EditorsSettingsSectionState();
}

class _EditorsSettingsSectionState extends State<EditorsSettingsSection> {
  Future<void> _getDefaultEditor() async {
    await SharedPreferences.getInstance();
    // TODO: Get the user preferred editor from the shared preferences.
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
        // TODO: Show if there is no default editor set.
        // if (defaultEditor == null)
        //   warningWidget(
        //     'You have no selected default editor. Choose one so we know what to open your projects with.',
        //     Assets.warn,
        //     kYellowColor,
        //   ),
        VSeparators.normal(),
        Row(
          children: <Widget>[
            Expanded(
              child: RectangleButton(
                height: 100,
                onPressed: () async {
                  // TODO: Set the default editor to VS Code.
                  // setState(() => defaultEditor = 'code');
                  // _pref = await SharedPreferences.getInstance();
                  // await _pref.setString('default_editor', 'code');
                },
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: Column(
                        children: <Widget>[
                          Expanded(child: SvgPicture.asset(Assets.vscode)),
                          Text(
                            'VS Code',
                            style: TextStyle(
                                color: customTheme.textTheme.bodyText1!.color),
                          ),
                        ],
                      ),
                    ),
                    // TODO: Show this checkmark if the default editor is VS Code.
                    // if (defaultEditor == 'code')
                    //   const Align(
                    //     alignment: Alignment.topLeft,
                    //     child: Padding(
                    //       padding: EdgeInsets.symmetric(horizontal: 5),
                    //       child: Icon(Icons.check, color: kGreenColor),
                    //     ),
                    //   ),
                  ],
                ),
              ),
            ),
            HSeparators.small(),
            Expanded(
              child: RectangleButton(
                height: 100,
                onPressed: () async {
                  // TODO: Set the default editor to Android Studio.
                  // setState(() => defaultEditor = 'studio64');
                  // _pref = await SharedPreferences.getInstance();
                  // await _pref.setString('default_editor', 'studio64');
                },
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: Column(
                        children: <Widget>[
                          Expanded(child: SvgPicture.asset(Assets.studio)),
                          Text(
                            'Android Studio',
                            style: TextStyle(
                                color: customTheme.textTheme.bodyText1!.color),
                          ),
                        ],
                      ),
                    ),
                    // TODO: Show this checkmark if the default editor is Android Studio.
                    // if (defaultEditor == 'studio64')
                    //   const Align(
                    //     alignment: Alignment.topLeft,
                    //     child: Padding(
                    //       padding: EdgeInsets.symmetric(horizontal: 5),
                    //       child: Icon(Icons.check, color: kGreenColor),
                    //     ),
                    //   ),
                  ],
                ),
              ),
            ),
            if (Platform.isMacOS) HSeparators.small(),
            if (Platform.isMacOS)
              Expanded(
                child: RectangleButton(
                  height: 100,
                  onPressed: () async {
                    // TODO: Set the default editor to Xcode.
                    // setState(() => defaultEditor = 'xcode');
                    // _pref = await SharedPreferences.getInstance();
                    // await _pref.setString('default_editor', 'xcode');
                  },
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Column(
                          children: <Widget>[
                            Expanded(child: Image.asset(Assets.xcode)),
                            Text(
                              'Xcode',
                              style: TextStyle(
                                  color:
                                      customTheme.textTheme.bodyText1!.color),
                            ),
                          ],
                        ),
                      ),
                      // TODO: Show this checkmark if the default editor is Xcode.
                      // if (defaultEditor == 'xcode')
                      //   const Align(
                      //     alignment: Alignment.topLeft,
                      //     child: Padding(
                      //       padding: EdgeInsets.symmetric(horizontal: 5),
                      //       child: Icon(Icons.check, color: kGreenColor),
                      //     ),
                      //   ),
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
