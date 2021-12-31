// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/shared_pref.dart';
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/core/libraries/utils.dart';
import 'package:manager/core/libraries/widgets.dart';

enum Editor { atom, sublime, vscode }

class OpenProjectOnEditor extends StatefulWidget {
  final String path;

  const OpenProjectOnEditor({
    Key? key,
    required this.path,
  }) : super(key: key);

  @override
  State<OpenProjectOnEditor> createState() => _OpenProjectOnEditorState();
}

class _OpenProjectOnEditorState extends State<OpenProjectOnEditor> {
  String? _selectedEditor;
  bool _rememberChoice = false;

  final List<String> _editors = <String>[
    'code',
    'studio64',
    'xcode',
  ];

  bool _showEditorSelection = false;

  Future<void> _loadProject() async {
    try {
      if (!SharedPref().pref.containsKey(SPConst.defaultEditor) && mounted) {
        setState(() => _showEditorSelection = true);
        return;
      } else if (mounted) {
        if (_editors
                .contains(SharedPref().pref.getString(SPConst.defaultEditor)) &&
            mounted) {
          switch (SharedPref().pref.getString(SPConst.defaultEditor)) {
            case 'code':
              await shell.cd(widget.path).run('code .');
              Navigator.pop(context);
              break;
            case 'studio64':
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                snackBarTile(context,
                    'Android Studio not supported yet. Select another editor instead.',
                    type: SnackBarType.warning, revert: true),
              );
              setState(() => _showEditorSelection = true);
              break;
            case 'xcode':
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                snackBarTile(context,
                    'Xcode not supported yet. Select another editor instead.',
                    type: SnackBarType.warning, revert: true),
              );
              setState(() => _showEditorSelection = true);
              break;
          }
          return;
        } else if (mounted) {
          await SharedPref().pref.remove(SPConst.defaultEditor);
          setState(() => _showEditorSelection = true);
          return;
        }
      }
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Couldn\'t open project',
          stackTraces: s);
      print(_);
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
          context,
          'Couldn\'t open this project! Please report this issue on GitHub.',
          type: SnackBarType.error,
          revert: true,
        ));
        Navigator.pop(context);
      }
    }
  }

  @override
  void initState() {
    Future<void>.delayed(Duration.zero, _loadProject);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          const DialogHeader(title: 'Select Editor'),
          VSeparators.normal(),
          if (_showEditorSelection) ...<Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: RoundContainer(
                    borderWith: 2,
                    borderColor: _selectedEditor == 'code'
                        ? kGreenColor
                        : Colors.transparent,
                    padding: EdgeInsets.zero,
                    child: RectangleButton(
                      height: 100,
                      onPressed: () => setState(() => _selectedEditor = 'code'),
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            Expanded(child: SvgPicture.asset(Assets.vscode)),
                            Text(
                              'VS Code',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .color),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                HSeparators.normal(),
                Expanded(
                  child: RoundContainer(
                    borderWith: 2,
                    borderColor: _selectedEditor == 'studio64'
                        ? kGreenColor
                        : Colors.transparent,
                    padding: EdgeInsets.zero,
                    child: RectangleButton(
                      height: 100,
                      onPressed: () =>
                          setState(() => _selectedEditor = 'studio64'),
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            Expanded(child: SvgPicture.asset(Assets.studio)),
                            Text(
                              'Android Studio',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .color),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (Platform.isMacOS) HSeparators.normal(),
                if (Platform.isMacOS)
                  Expanded(
                    child: RoundContainer(
                      borderWith: 2,
                      borderColor: _selectedEditor == 'xcode'
                          ? kGreenColor
                          : Colors.transparent,
                      padding: EdgeInsets.zero,
                      child: RectangleButton(
                        height: 100,
                        onPressed: () =>
                            setState(() => _selectedEditor = 'xcode'),
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              Expanded(child: Image.asset(Assets.xCode)),
                              Text(
                                'Xcode',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            VSeparators.normal(),
            CheckBoxElement(
              onChanged: (bool? val) =>
                  setState(() => _rememberChoice = val ?? false),
              value: _rememberChoice,
              text: 'Remember my choice next time',
            ),
            Align(
              alignment: Alignment.centerRight,
              child: RectangleButton(
                width: 100,
                child: const Text('Open'),
                onPressed: () async {
                  if (_selectedEditor == null) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      snackBarTile(
                          context, 'Please select an editor before proceeding.',
                          type: SnackBarType.error, revert: true),
                    );
                    return;
                  }

                  if (_rememberChoice) {
                    await SharedPref()
                        .pref
                        .setString(SPConst.defaultEditor, _selectedEditor!);
                  }

                  switch (_selectedEditor) {
                    case 'code':
                      await shell.cd(widget.path).run('code .');
                      Navigator.pop(context);
                      break;
                    case 'studio64':
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        snackBarTile(context,
                            'Android Studio not supported yet. Select another editor instead in settings.',
                            type: SnackBarType.warning, revert: true),
                      );
                      Navigator.pop(context);
                      break;
                    case 'xcode':
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        snackBarTile(context,
                            'Xcode not supported yet. Select another editor instead in settings.',
                            type: SnackBarType.warning, revert: true),
                      );
                      Navigator.pop(context);
                      break;
                  }
                },
              ),
            ),
          ] else
            const Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: SizedBox(
                width: 20,
                height: 20,
                child: Spinner(size: 10, thickness: 2),
              ),
            ),
        ],
      ),
    );
  }
}
