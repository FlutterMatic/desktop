import 'package:flutter/material.dart';
import 'package:file_chooser/file_chooser.dart';
import 'package:flutter_installer/components/widgets/inputs/multiple_choice.dart';
import 'package:flutter_installer/components/widgets/ui/round_container.dart';
import 'package:flutter_installer/utils/constants.dart';
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
  void dispose() {
    _dirPath = null;
    _editorOption = null;
    _dirPathError = false;
    super.dispose();
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
                  _dirPath ?? 'Fetching your preffered project directory',
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
                    setState(() => _dirPath = fileResult.paths!.first);
                    await _pref.setString(
                        'projects_path', fileResult.paths!.first);
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
          defaultChoiceValue: _editorOption,
          onChanged: (val) async {
            setState(() => _editorOption = val);
            _pref = await SharedPreferences.getInstance();
            await _pref.setString('editor_option', val);
          },
        ),
      ],
    );
  }
}
