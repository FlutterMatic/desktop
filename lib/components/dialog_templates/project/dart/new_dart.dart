// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/app/constants/shared_pref.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/dialog_templates/project/common/name.dart';
import 'package:fluttermatic/components/dialog_templates/project/created.dart';
import 'package:fluttermatic/components/dialog_templates/project/dart/sections/template.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/beta_tile.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/linear_progress_indicator.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/core/services/actions/dart.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/shared_pref.dart';

class NewDartProjectDialog extends StatefulWidget {
  const NewDartProjectDialog({Key? key}) : super(key: key);

  @override
  _NewDartProjectDialogState createState() => _NewDartProjectDialogState();
}

class _NewDartProjectDialogState extends State<NewDartProjectDialog> {
  // Input Controllers
  final TextEditingController _nameController = TextEditingController();

  String _template = 'console-simple';

  _NewProjectSections _index = _NewProjectSections.projectName;

  final GlobalKey<FormState> _createProjectFormKey = GlobalKey<FormState>();

  bool _projectNameCondition() =>
      _nameController.text != '' &&
      _nameController.text.startsWith(RegExp('[a-zA-Z]')) &&
      !_nameController.text.contains(RegExp('[0-9]'));

  bool _projectPathCondition() =>
      _path != null && Directory(_path!).existsSync();

  String? _path = SharedPref().pref.getString(SPConst.projectsPath);

  bool _confirmDirectory() {
    List<FileSystemEntity> _dirs = Directory(_path!).listSync();

    // Make sure that there is no directory with the same name
    for (FileSystemEntity dir in _dirs) {
      String _existName = dir.path.split('\\').last.toLowerCase();

      if (_existName == _nameController.text.toLowerCase()) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          snackBarTile(
            context,
            'There is already a directory with the same name. Please choose another name.',
            type: SnackBarType.error,
          ),
        );

        return false;
      }
    }

    return true;
  }

  Future<void> _createNewProject() async {
    if (_createProjectFormKey.currentState!.validate()) {
      // Name
      if (_index == _NewProjectSections.projectName &&
          _projectNameCondition()) {
        if (!_projectPathCondition()) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            snackBarTile(
              context,
              'Please select a valid path to save project to.',
              type: SnackBarType.error,
            ),
          );

          return;
        }

        // Make sure that this project name doesn't already exist in the
        // selected path.
        bool _confirm = _confirmDirectory();

        if (_confirm) {
          setState(() {
            _nameController.text = _nameController.text.toLowerCase();
            _index = _NewProjectSections.projectTemplate;
          });
        }
      } else if (_index == _NewProjectSections.projectTemplate) {
        try {
          // Make sure that this project name doesn't already exist in the
          // selected path.
          bool _confirm = _confirmDirectory();

          if (_confirm) {
            setState(() => _index = _NewProjectSections.creatingProject);

            String _result = await DartActionServices.createNewProject(
              NewDartProjectInfo(
                projectName: _nameController.text,
                projectPath: _path!,
                template: _template,
              ),
            );

            if (_result == 'success') {
              Navigator.pop(context);

              await showDialog(
                context: context,
                builder: (_) => ProjectCreatedDialog(
                  projectName: _nameController.text,
                  projectPath: _path! + '\\' + _nameController.text,
                ),
              );

              return;
            }

            setState(() => _index = _NewProjectSections
                .values[_NewProjectSections.values.length - 2]);

            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              snackBarTile(
                context,
                _result,
                type: SnackBarType.error,
              ),
            );
          }
        } catch (_, s) {
          await logger.file(
              LogTypeTag.error, 'Failed to create new Flutter project: $_',
              stackTraces: s);
          ScaffoldMessenger.of(context).showSnackBar(
            snackBarTile(
              context,
              'Failed to create project. Please file an issue.',
              type: SnackBarType.error,
            ),
          );
          setState(() => _index = _NewProjectSections
              .values[_NewProjectSections.values.length - 2]);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _index != _NewProjectSections.creatingProject,
      child: DialogTemplate(
        outerTapExit: false,
        child: Column(
          children: <Widget>[
            DialogHeader(
              title: 'Dart Project',
              leading: _index != _NewProjectSections.projectName &&
                      _index != _NewProjectSections.creatingProject
                  ? SquareButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                      color: Colors.transparent,
                      onPressed: () => setState(() => _index =
                          _NewProjectSections.values[_index.index - 1]),
                    )
                  : const StageTile(stageType: StageType.prerelease),
            ),
            Form(
              key: _createProjectFormKey,
              child: Column(
                children: <Widget>[
                  // Project Name
                  if (_index == _NewProjectSections.projectName)
                    ProjectNameSection(
                      path: _path,
                      controller: _nameController,
                      onPathUpdate: (String path) =>
                          setState(() => _path = path),
                    ),
                  if (_index == _NewProjectSections.projectTemplate)
                    DartProjectTemplateSection(
                      onTemplateSelected: (String template) =>
                          setState(() => _template = template),
                      selectedTemplate: _template,
                    ),
                ],
              ),
            ),
            VSeparators.normal(),
            // Creating Project Indicator
            if (_index == _NewProjectSections.creatingProject)
              Padding(
                padding: const EdgeInsets.only(left: 50, right: 50, top: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const CustomLinearProgressIndicator(),
                    VSeparators.xLarge(),
                    const Text(
                      'Creating new project. Hold on tight.',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            VSeparators.small(),
            // Cancel & Next Buttons
            if (_index != _NewProjectSections.creatingProject)
              Row(
                children: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Text('Cancel'),
                    ),
                  ),
                  const Spacer(),
                  RectangleButton(
                    radius: BorderRadius.circular(5),
                    onPressed: _createNewProject,
                    width: 120,
                    child: Text(
                      _index ==
                              _NewProjectSections
                                  .values[_NewProjectSections.values.length - 2]
                          ? 'Create'
                          : 'Next',
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

enum _NewProjectSections {
  projectName,
  projectTemplate,
  creatingProject,
}
