import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/dialog_header.dart';
import 'package:flutter_installer/components/widgets/check_box_element.dart';
import 'package:flutter_installer/components/widgets/dialog_template.dart';
import 'package:flutter_installer/components/widgets/info_widget.dart';
import 'package:flutter_installer/components/widgets/multiple_choice.dart';
import 'package:flutter_installer/components/widgets/rectangle_button.dart';
import 'package:flutter_installer/components/widgets/round_container.dart';
import 'package:flutter_installer/components/widgets/warning_widget.dart';
import 'package:flutter_installer/services/themes.dart';
import 'package:file_chooser/file_chooser.dart' show showOpenPanel;
import 'package:file_chooser/src/result.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class SettingDialog extends StatefulWidget {
  @override
  _SettingDialogState createState() => _SettingDialogState();
}

class _SettingDialogState extends State<SettingDialog> {
  //Utils
  late SharedPreferences _pref;
  bool _dirPathError = false;
  bool _loading = false;
  bool _requireTruShoot = false;

  //Troubleshoot
  bool truShootFullApp = false;
  bool truShootFlutter = false;
  bool truShootStudio = false;
  bool truShootVSC = false;

  Future<void> _closeActivity() async {
    setState(() {
      _dirPathError = false;
      _loading = false;
    });
    if (_dirPath == null) {
      setState(() => _dirPathError = true);
    } else {
      setState(() => _loading = true);
      _pref = await SharedPreferences.getInstance();
      await _pref.setString('projects_path', _dirPath!);
      if (_dirChanged) {
        await Navigator.pushNamedAndRemoveUntil(
            context, PageRoutes.routeState, (route) => false);
      }
      Navigator.pop(context);
    }
  }

  //User Inputs
  bool _dirChanged = false;
  String? _dirPath;
  String? _defaultProjectChoice;

  Future<void> _getProjectPath() async {
    _pref = await SharedPreferences.getInstance();
    setState(() => _dirPath = _pref.getString('projects_path'));
  }

  Future<void> _getDefaultEditor() async {
    _pref = await SharedPreferences.getInstance();
    if (_pref.containsKey('default_editor')) {
      setState(() => defaultEditor = _pref.getString('default_editor'));
    }
  }

  Future<void> _getEditorOptions() async {
    _pref = await SharedPreferences.getInstance();
    if (_pref.containsKey('editor_option')) {
      setState(() => _defaultProjectChoice = _pref.getString('editor_option'));
    }
  }

  void _checkTroubleShoot() {
    setState(() => _requireTruShoot = false);
    if (truShootFullApp) {
      setState(() {
        truShootFlutter = false;
        truShootStudio = false;
        truShootVSC = false;
      });
    }
  }

  void _startTroubleshoot() {
    setState(() => _requireTruShoot = false);
    if (truShootFlutter == false &&
        truShootFullApp == false &&
        truShootStudio == false &&
        truShootVSC == false) {
      setState(() => _requireTruShoot = true);
    }
  }

  @override
  void initState() {
    _getProjectPath();
    _getDefaultEditor();
    _getEditorOptions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return DialogTemplate(
      width: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DialogHeader(title: 'Settings', onClose: _closeActivity),
          const SizedBox(height: 20),
          TabViewWidget(
            tabNames: ['Theme', 'Projects', 'Editors', 'GitHub', 'Troublshoot'],
            tabItems: [
              //Themes
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Themes',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 15),
                  _themeTiles(context, !currentTheme.isDarkTheme, 'Light Mode',
                      'Get a bright and shining desktop', () {
                    if (currentTheme.isDarkTheme) currentTheme.toggleTheme();
                  }),
                  const SizedBox(height: 10),
                  _themeTiles(context, currentTheme.isDarkTheme, 'Dark Mode',
                      'For dark and nighty appearence', () {
                    if (!currentTheme.isDarkTheme) currentTheme.toggleTheme();
                  }),
                ],
              ),
              //Projects
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Project Path',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 15),
                  RoundContainer(
                    borderColor: _dirPathError ? kRedColor : Colors.transparent,
                    borderWith: 2,
                    width: double.infinity,
                    radius: 5,
                    color: Colors.blueGrey.withOpacity(0.2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _dirPath ??
                                'Fetching your preffered project directory',
                            overflow: TextOverflow.fade,
                            softWrap: false,
                          ),
                        ),
                        IconButton(
                          color: Colors.transparent,
                          icon: Icon(
                            Icons.edit_outlined,
                            color: customTheme.textTheme.bodyText1!.color,
                          ),
                          onPressed: () async {
                            FileChooserResult fileResult = await showOpenPanel(
                              allowedFileTypes: [],
                              initialDirectory: _dirPath,
                              canSelectDirectories: true,
                            );
                            if (fileResult.paths!.isNotEmpty) {
                              setState(() {
                                _dirPath = fileResult.paths!.first;
                                _dirChanged = true;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Editor Options',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 15),
                  MultipleChoice(
                    options: [
                      'Always open projects in preferred editor',
                      'Ask me which editor to open with every time',
                    ],
                    defaultChoiceValue: _defaultProjectChoice,
                    onChanged: (val) =>
                        setState(() => _defaultProjectChoice = val),
                  ),
                ],
              ),
              //Editors
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    children: [
                      Expanded(
                        child: RectangleButton(
                          height: 100,
                          onPressed: () async {
                            setState(() => defaultEditor = 'code');
                            _pref = await SharedPreferences.getInstance();
                            await _pref.setString('default_editor', 'code');
                          },
                          child: Stack(
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: SvgPicture.asset(Assets.vscode),
                                    ),
                                    Text(
                                      'VS Code',
                                      style: TextStyle(
                                          color: customTheme
                                              .textTheme.bodyText1!.color),
                                    ),
                                  ],
                                ),
                              ),
                              if (defaultEditor == 'code')
                                const Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                    child:
                                        Icon(Icons.check, color: kGreenColor),
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
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: SvgPicture.asset(
                                          Assets.androidStudio),
                                    ),
                                    Text(
                                      'Android Studio',
                                      style: TextStyle(
                                          color: customTheme
                                              .textTheme.bodyText1!.color),
                                    ),
                                  ],
                                ),
                              ),
                              if (defaultEditor == 'studio64')
                                const Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                    child:
                                        Icon(Icons.check, color: kGreenColor),
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
                              children: [
                                Center(
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: SvgPicture.asset(Assets.xcode),
                                      ),
                                      Text(
                                        'Xcode',
                                        style: TextStyle(
                                            color: customTheme
                                                .textTheme.bodyText1!.color),
                                      ),
                                    ],
                                  ),
                                ),
                                if (defaultEditor == 'xcode')
                                  const Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      child:
                                          Icon(Icons.check, color: kGreenColor),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              //GitHub
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GitHub',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: RectangleButton(
                          height: 100,
                          onPressed: () {
                            launch(
                                'https://github.com/FlutterMatic/FlutterMatic-desktop/issues');
                            Navigator.pop(context);
                          },
                          child: Column(
                            children: [
                              Expanded(
                                child: Icon(
                                  Iconsdata.gitIssue,
                                  size: 30,
                                  color: customTheme.iconTheme.color,
                                ),
                              ),
                              Text(
                                'Create Issue',
                                style: TextStyle(
                                    color:
                                        customTheme.textTheme.bodyText1!.color),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RectangleButton(
                          height: 100,
                          onPressed: () {
                            launch(
                                'https://github.com/FlutterMatic/FlutterMatic-desktop/pulls');
                            Navigator.pop(context);
                          },
                          child: Column(
                            children: [
                              Expanded(
                                child: Icon(Iconsdata.gitPR,
                                    size: 30,
                                    color: customTheme.iconTheme.color),
                              ),
                              Text(
                                'Pull Request',
                                style: TextStyle(
                                    color:
                                        customTheme.textTheme.bodyText1!.color),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Contributions',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  infoWidget(
                      'We are open-source! We would love to see you make some pull requests to this app!'),
                ],
              ),
              //Troubleshoot
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Troubleshooting',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 15),
                  CheckBoxElement(
                    onChanged: (val) {
                      setState(() => truShootFullApp = !truShootFullApp);
                      _checkTroubleShoot();
                    },
                    value: truShootFullApp,
                    text: 'All Applications',
                  ),
                  CheckBoxElement(
                    onChanged: (val) {
                      setState(() => truShootFlutter = !truShootFlutter);
                      _checkTroubleShoot();
                    },
                    value: truShootFlutter,
                    text: 'Flutter',
                  ),
                  CheckBoxElement(
                    onChanged: (val) {
                      setState(() => truShootStudio = !truShootStudio);
                      _checkTroubleShoot();
                    },
                    value: truShootStudio,
                    text: 'Android Studio',
                  ),
                  CheckBoxElement(
                    onChanged: (val) {
                      setState(() => truShootVSC = !truShootVSC);
                      _checkTroubleShoot();
                    },
                    value: truShootVSC,
                    text: 'Visual Studio Code',
                  ),
                  if (_requireTruShoot)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: warningWidget(
                          'You need to choose at least one troubleshoot option.',
                          Assets.error,
                          kRedColor),
                    ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: RectangleButton(
                      width: 150,
                      onPressed: _startTroubleshoot,
                      child: Text(
                        'Start Troubleshoot',
                        style: TextStyle(
                            color: customTheme.textTheme.bodyText1!.color),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  RoundContainer(
                    color: Colors.blueGrey.withOpacity(0.2),
                    width: double.infinity,
                    child: SelectableText(
                      'Flutter Installer Version $desktopVersion - Stable',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
          RectangleButton(
            loading: _loading,
            onPressed: _closeActivity,
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
  final List<String> tabNames;
  final List<Widget> tabItems;

  TabViewWidget({required this.tabNames, required this.tabItems})
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
      children: [
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

Widget _themeTiles(BuildContext context, bool selected, String title,
    String description, Function() onPressed) {
  ThemeData customTheme = Theme.of(context);
  return RectangleButton(
    height: 65,
    width: double.infinity,
    hoverColor: Colors.transparent,
    onPressed: onPressed,
    padding: const EdgeInsets.all(10),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      color: customTheme.textTheme.bodyText1!.color,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: customTheme.textTheme.bodyText1!.color!
                          .withOpacity(0.6)),
                ),
              ],
            ),
          ),
          selected
              ? const Icon(Icons.check_rounded, color: kGreenColor)
              : const SizedBox.shrink()
        ],
      ),
    ),
  );
}
