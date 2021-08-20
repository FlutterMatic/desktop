import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart' as file_selector;
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/core/services/logs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectsSettingsSection extends StatefulWidget {
  @override
  _ProjectsSettingsSectionState createState() =>
      _ProjectsSettingsSectionState();
}

class _ProjectsSettingsSectionState extends State<ProjectsSettingsSection> {
  late SharedPreferences _pref;
  bool _dirPathError = false;

  //User Inputs
  String? _dirPath;
  String? _editorOption;

  Future<void> _getEditorOptions() async {
    _pref = await SharedPreferences.getInstance();
    if (_pref.containsKey('editor_option')) {
      setState(() => _editorOption = _pref.getString('editor_option'));
    }
  }

  Future<void> _getProjectPath() async {
    _pref = await SharedPreferences.getInstance();
    setState(() => _dirPath = _pref.getString('projects_path'));
  }

  @override
  void initState() {
    _getEditorOptions();
    _getProjectPath();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
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
            children: <Widget>[
              Expanded(
                child: Text(
                  _dirPath ?? 'Fetching your preferred project directory',
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
                  String? projectsDirectory;
                  String? directoryPath = await file_selector.getDirectoryPath(
                    initialDirectory: projectsDirectory,
                    confirmButtonText: 'Choose this',
                  );
                  if (directoryPath != null) {
                    setState(() => _dirPath = directoryPath);
                    await _pref.setString('projects_path', directoryPath);
                  } else {
                    await logger.file(
                        LogTypeTag.WARNING, 'Path was not chosen');
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
          options: <String>[
            'Always open projects in preferred editor',
            'Ask me which editor to open with every time',
          ],
          defaultChoiceValue: _editorOption,
          onChanged: (String val) async {
            setState(() => _editorOption = val);
            _pref = await SharedPreferences.getInstance();
            await _pref.setString('editor_option', val);
          },
        ),
      ],
    );
  }
}
