// 🐦 Flutter imports:

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/shared_pref.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/inputs/check_box_element.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/components/widgets/ui/spinner.dart';
import 'package:fluttermatic/components/widgets/ui/stage_tile.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/general/shared_pref.dart';

class OpenProjectInEditor extends StatefulWidget {
  final String path;

  const OpenProjectInEditor({
    Key? key,
    required this.path,
  }) : super(key: key);

  @override
  State<OpenProjectInEditor> createState() => _OpenProjectInEditorState();
}

class _OpenProjectInEditorState extends State<OpenProjectInEditor> {
  String? _selectedEditor;
  bool _rememberChoice = false;

  final List<String> _editors = <String>[
    'code',
    'studio64',
  ];

  bool _showEditorSelection = false;

  Future<void> _openProject(String? editor) async {
    switch (editor) {
      case 'code':
        await shell.cd(widget.path).run('code .');

        if (mounted) {
          Navigator.pop(context);
        }
        break;
      case 'studio':
        // TODO: Support opening projects in Android Studio
        // if (Platform.isMacOS) {
        //   await shell.cd(widget.path).run(
        //       'open -a /Applications/Android\\ Studio.app /${widget.path}');
        // } else if (Platform.isMacOS) {
        //   await shell.cd(widget.path).run(
        //       '"${context.read<SpaceCheck>().drive}:\\Program Files\\Android\\Android Studio\\bin\\studio64.exe" "X:${widget.path}"');
        // }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          snackBarTile(
            context,
            'Android Studio not supported yet. Select another editor instead.',
            type: SnackBarType.warning,
          ),
        );
        Navigator.pop(context);
        break;
      default:
        setState(() => _showEditorSelection = true);
        await SharedPref().pref.remove(SPConst.defaultEditor);
        await SharedPref().pref.remove(SPConst.askEditorAlways);
        await logger.file(LogTypeTag.warning,
            'Found editor choice conflicts with settings choice.');
        break;
    }
  }

  Future<void> _loadProject() async {
    try {
      if (!SharedPref().pref.containsKey(SPConst.askEditorAlways) ||
          SharedPref().pref.containsKey(SPConst.askEditorAlways) &&
              SharedPref().pref.getBool(SPConst.askEditorAlways) == true) {
        setState(() => _showEditorSelection = true);

        await SharedPref().pref.setBool(SPConst.askEditorAlways, true);

        return;
      }

      if (!SharedPref().pref.containsKey(SPConst.defaultEditor)) {
        setState(() => _showEditorSelection = true);
        return;
      } else if (mounted) {
        if (_editors
                .contains(SharedPref().pref.getString(SPConst.defaultEditor)) &&
            mounted) {
          // Open the project with the default set editor.
          await _openProject(
              SharedPref().pref.getString(SPConst.defaultEditor));

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

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
          context,
          'Couldn\'t open this project! Please report this issue on GitHub.',
          type: SnackBarType.error,
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
          const DialogHeader(
            title: 'Select Editor',
            leading: StageTile(),
          ),
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
                      color: Colors.transparent,
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
                    borderColor: _selectedEditor == 'studio'
                        ? kGreenColor
                        : Colors.transparent,
                    padding: EdgeInsets.zero,
                    child: RectangleButton(
                      color: Colors.transparent,
                      height: 100,
                      onPressed: () =>
                          setState(() => _selectedEditor = 'studio'),
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
              ],
            ),
            VSeparators.normal(),
            RoundContainer(
              child: CheckBoxElement(
                onChanged: (bool? val) async {
                  val = !(val ?? false);

                  setState(() => _rememberChoice = !(val ?? false));
                  await SharedPref().pref.setBool(SPConst.askEditorAlways, val);
                },
                value: _rememberChoice,
                text: 'Remember my choice next time',
              ),
            ),
            VSeparators.normal(),
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
                        context,
                        'Please select an editor before proceeding.',
                        type: SnackBarType.error,
                      ),
                    );
                    return;
                  }

                  if (_rememberChoice) {
                    await SharedPref().pref.setString(
                        SPConst.defaultEditor, _selectedEditor ?? 'code');
                  }

                  // Open the project in the selected editor.
                  await _openProject(_selectedEditor);
                },
              ),
            ),
          ] else
            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 30),
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
