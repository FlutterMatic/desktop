// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:file_selector/file_selector.dart' as file_selector;

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/core/services/logs.dart';
import 'package:manager/meta/utils/shared_pref.dart';

class ProjectsSettingsSection extends StatefulWidget {
  const ProjectsSettingsSection({Key? key}) : super(key: key);

  @override
  _ProjectsSettingsSectionState createState() =>
      _ProjectsSettingsSectionState();
}

class _ProjectsSettingsSectionState extends State<ProjectsSettingsSection> {
  // User Inputs
  String? _dirPath;
  String? _editorOption;
  bool _dirPathError = false;

  Future<void> _getEditorOptions() async {
    if (SharedPref().pref.containsKey('Editor_Option')) {
      setState(
          () => _editorOption = SharedPref().pref.getString('Editor_Option'));
    } else {
      setState(() => _editorOption = 'always_ask');
      await SharedPref().pref.setString('Editor_Option', 'always_ask');
    }
  }

  Future<void> _getProjectPath() async {
    if (SharedPref().pref.containsKey('Projects_Path')) {
      setState(() => _dirPath = SharedPref().pref.getString('Projects_Path'));
    } else {
      setState(() => _dirPathError = true);
    }
  }

  @override
  void initState() {
    _dirPathError = false;
    _getEditorOptions();
    _getProjectPath();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return TabViewTabHeadline(
      title: 'Projects',
      content: <Widget>[
        if (_dirPathError)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: informationWidget(
              'Couldn\'t fetch your projects path. Try settings your projects path.',
              type: InformationType.error,
            ),
          ),
        RoundContainer(
          color: Colors.blueGrey.withOpacity(0.2),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  _dirPath ??
                      (_dirPathError
                          ? 'Couldn\'t fetch your projects path. Try settings your path'
                          : 'Fetching your preferred project directory'),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              ),
              if (_dirPath == null && !_dirPathError)
                const Spinner(size: 15, thickness: 2)
              else
                IconButton(
                  color: Colors.transparent,
                  icon: Icon(
                    Icons.edit_outlined,
                    color: customTheme.textTheme.bodyText1!.color,
                  ),
                  onPressed: () async {
                    String? _projectsDirectory;
                    String? _directoryPath =
                        await file_selector.getDirectoryPath(
                      initialDirectory: _projectsDirectory,
                      confirmButtonText: 'Confirm',
                    );
                    if (_directoryPath != null) {
                      setState(() {
                        _dirPathError = false;
                        _dirPath = _directoryPath;
                      });
                      await SharedPref()
                          .pref
                          .setString('Projects_Path', _directoryPath);

                      await logger.file(LogTypeTag.info,
                          'Projects path was set to: $_directoryPath');
                    } else {
                      await logger.file(
                          LogTypeTag.warning, 'Projects path was not chosen');
                    }
                  },
                ),
            ],
          ),
        ),
        VSeparators.large(),
        const Text(
          'Editor Options',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        VSeparators.normal(),
        MultipleChoice(
          options: const <String>[
            'Always open projects in preferred editor',
            'Ask me which editor to open with every time',
          ],
          defaultChoiceValue: _editorOption == 'always_ask'
              ? 'Ask me which editor to open with every time'
              : 'Always open projects in preferred editor',
          onChanged: (String val) async {
            String _newVal =
                val == 'Ask me which editor to open with every time'
                    ? 'always_ask'
                    : 'preferred_editor';
            setState(() => _editorOption = _newVal);
            await SharedPref().pref.setString('Editor_Option', _newVal);
            await logger.file(
                LogTypeTag.info, 'Editor option was set to: $_newVal');
          },
        ),
      ],
    );
  }
}
