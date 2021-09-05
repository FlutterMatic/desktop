import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/meta/utils/shared_pref.dart';
import 'dart:io';

class EditorsSettingsSection extends StatefulWidget {
  @override
  _EditorsSettingsSectionState createState() => _EditorsSettingsSectionState();
}

class _EditorsSettingsSectionState extends State<EditorsSettingsSection> {
  String? _defaultEditor;

  Future<void> _getDefaultEditor() async {
    if (SharedPref().pref.containsKey('Default_Editor')) {
      setState(
          () => _defaultEditor = SharedPref().pref.getString('Default_Editor'));
    } else {
      setState(() => _defaultEditor = 'code');
      await SharedPref().pref.setString('Default_Editor', 'code');
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
    return TabViewTabHeadline(
      title: 'Editors',
      content: <Widget>[
        if (_defaultEditor == null)
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: informationWidget(
              'You have no selected default editor. Choose one so we know what to open your projects with.',
              type: InformationType.warning,
            ),
          ),
        Row(
          children: <Widget>[
            Expanded(
              child: RoundContainer(
                borderWith: 2,
                borderColor:
                    _defaultEditor == 'code' ? kGreenColor : Colors.transparent,
                padding: EdgeInsets.zero,
                child: RectangleButton(
                  height: 100,
                  onPressed: () async {
                    setState(() => _defaultEditor = 'code');
                    await SharedPref().pref.setString('Default_Editor', 'code');
                  },
                  child: Center(
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
                ),
              ),
            ),
            HSeparators.small(),
            Expanded(
              child: RoundContainer(
                borderWith: 2,
                borderColor: _defaultEditor == 'studio64'
                    ? kGreenColor
                    : Colors.transparent,
                padding: EdgeInsets.zero,
                child: RectangleButton(
                  height: 100,
                  onPressed: () async {
                    setState(() => _defaultEditor = 'studio64');
                    await SharedPref()
                        .pref
                        .setString('Default_Editor', 'studio64');
                  },
                  child: Center(
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
                ),
              ),
            ),
          ],
        ),
        VSeparators.small(),
        Row(
          children: <Widget>[
            if (Platform.isMacOS)
              Expanded(
                child: RoundContainer(
                  borderWith: 2,
                  borderColor: _defaultEditor == 'xcode'
                      ? kGreenColor
                      : Colors.transparent,
                  padding: EdgeInsets.zero,
                  child: RectangleButton(
                    height: 100,
                    onPressed: () async {
                      setState(() => _defaultEditor = 'xcode');
                      await SharedPref()
                          .pref
                          .setString('Default_Editor', 'xcode');
                    },
                    child: Center(
                      child: Column(
                        children: <Widget>[
                          Expanded(child: Image.asset(Assets.xcode)),
                          Text(
                            'Xcode',
                            style: TextStyle(
                                color: customTheme.textTheme.bodyText1!.color),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            HSeparators.small(),
            const Spacer(),
          ],
        ),
      ],
    );
  }
}
