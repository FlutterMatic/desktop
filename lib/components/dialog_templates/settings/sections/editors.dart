// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/app/constants/shared_pref.dart';
import 'package:fluttermatic/core/libraries/widgets.dart';
import 'package:fluttermatic/meta/utils/shared_pref.dart';

class EditorsSettingsSection extends StatefulWidget {
  const EditorsSettingsSection({Key? key}) : super(key: key);

  @override
  _EditorsSettingsSectionState createState() => _EditorsSettingsSectionState();
}

class _EditorsSettingsSectionState extends State<EditorsSettingsSection> {
  String? _defaultEditor;
  bool _askEditorAlways = false;

  Future<void> _getDefaultEditor() async {
    if (SharedPref().pref.containsKey(SPConst.askEditorAlways)) {
      setState(() {
        _askEditorAlways =
            SharedPref().pref.getBool(SPConst.askEditorAlways) ?? false;
      });
    }
    if (SharedPref().pref.containsKey(SPConst.defaultEditor)) {
      setState(() =>
          _defaultEditor = SharedPref().pref.getString(SPConst.defaultEditor));
    } else {
      setState(() => _defaultEditor = 'code');
      await SharedPref().pref.setString(SPConst.defaultEditor, 'code');
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
        if (_defaultEditor == null && !_askEditorAlways)
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: informationWidget(
              'You have no selected default editor. Choose one so we know what to open your projects with.',
              type: InformationType.warning,
            ),
          ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: _askEditorAlways ? 0.5 : 1,
          child: IgnorePointer(
            ignoring: _askEditorAlways,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RoundContainer(
                    borderWith: 2,
                    borderColor: _defaultEditor == 'code'
                        ? kGreenColor
                        : Colors.transparent,
                    padding: EdgeInsets.zero,
                    child: RectangleButton(
                      height: 100,
                      onPressed: () async {
                        setState(() => _defaultEditor = 'code');
                        await SharedPref()
                            .pref
                            .setString(SPConst.defaultEditor, 'code');
                      },
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            Expanded(child: SvgPicture.asset(Assets.vscode)),
                            Text(
                              'VS Code',
                              style: TextStyle(
                                  color:
                                      customTheme.textTheme.bodyText1!.color),
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
                            .setString(SPConst.defaultEditor, 'studio64');
                      },
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            Expanded(child: SvgPicture.asset(Assets.studio)),
                            Text(
                              'Android Studio',
                              style: TextStyle(
                                  color:
                                      customTheme.textTheme.bodyText1!.color),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        VSeparators.small(),
        CheckBoxElement(
          onChanged: (bool? val) async {
            val = val ?? false; // Ensures not `null`.

            if (val) {
              setState(() => _askEditorAlways = true);
              await SharedPref().pref.setBool(SPConst.askEditorAlways, true);
            } else {
              setState(() => _askEditorAlways = false);
              await SharedPref().pref.setBool(SPConst.askEditorAlways, false);
            }
          },
          value: _askEditorAlways,
          text: 'Always ask me which editor to use',
        ),
        HSeparators.small(),
      ],
    );
  }
}
