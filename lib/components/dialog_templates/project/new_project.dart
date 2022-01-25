// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/app/constants/shared_pref.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/dialog_templates/project/sections/description.dart';
import 'package:fluttermatic/components/dialog_templates/project/sections/name.dart';
import 'package:fluttermatic/components/dialog_templates/project/sections/org_name.dart';
import 'package:fluttermatic/components/dialog_templates/project/sections/platforms.dart';
import 'package:fluttermatic/components/dialog_templates/project/sections/pre_config.dart';
import 'package:fluttermatic/core/libraries/services.dart';
import 'package:fluttermatic/core/libraries/utils.dart';
import 'package:fluttermatic/core/libraries/widgets.dart';
import 'package:fluttermatic/core/services/actions/flutter.dart';
import 'package:fluttermatic/meta/views/dialogs/open_project.dart';

class NewProjectDialog extends StatefulWidget {
  const NewProjectDialog({Key? key}) : super(key: key);

  @override
  _NewProjectDialogState createState() => _NewProjectDialogState();
}

class _NewProjectDialogState extends State<NewProjectDialog> {
  // Input Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _orgController = TextEditingController();

  // Utils
  _NewProjectSections _index = _NewProjectSections.projectName;

  final GlobalKey<FormState> _createProjectFormKey = GlobalKey<FormState>();

  // Platforms
  bool _ios = true;
  bool _android = true;
  bool _web = true;
  bool _windows = true;
  bool _macos = true;
  bool _linux = true;

  bool _projectNameCondition() =>
      _nameController.text != '' &&
      _nameController.text.startsWith(RegExp('[a-zA-Z]')) &&
      !_nameController.text.contains(RegExp('[0-9]'));

  bool _projectPathCondition() =>
      _path != null && Directory(_path!).existsSync();

  bool _validateOrgName() =>
      _orgController.text != '' &&
      _orgController.text.contains('.') &&
      _orgController.text.contains(RegExp('[A-Za-z_]')) &&
      !_orgController.text.endsWith('.') &&
      !_orgController.text.endsWith('_');

  String? _path = SharedPref().pref.getString(SPConst.projectsPath);
  String? _currentActivity;

  // Pre Config
  Map<String, dynamic>? _firebaseJson;

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

        // Make sure that there is no directory with the same name
        if (Directory(_path! + '/' + _nameController.text).existsSync()) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            snackBarTile(
              context,
              'There is already a directory with the same name. Please choose another name.',
              type: SnackBarType.error,
            ),
          );

          return;
        }

        setState(() {
          _nameController.text = _nameController.text.toLowerCase();
          _index = _NewProjectSections.projectDescription;
        });
      }
      // Description
      else if (_index == _NewProjectSections.projectDescription) {
        setState(() => _index = _NewProjectSections.projectOrgName);
      }
      // Organization Name
      else if (_index == _NewProjectSections.projectOrgName &&
          _validateOrgName()) {
        setState(() => _index = _NewProjectSections.projectPlatforms);
      }
      // Platforms
      else if (_index == _NewProjectSections.projectPlatforms) {
        bool _isValid = validatePlatformSelection(
          ios: _ios,
          android: _android,
          web: _web,
          windows: _windows,
          macos: _macos,
          linux: _linux,
        );

        if (_isValid) {
          setState(() => _index = _NewProjectSections.preConfigProject);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            snackBarTile(
              context,
              'Please select appropriate platforms.',
              type: SnackBarType.error,
            ),
          );
        }
      } else if (_index == _NewProjectSections.preConfigProject) {
        try {
          setState(() => _index = _NewProjectSections.creatingProject);

          String _result = await FlutterActionServices.createNewProject(
            NewFlutterProjectInfo(
              projectPath: _path ?? '',
              projectName: _nameController.text,
              description: _descriptionController.text,
              orgName: _orgController.text,
              firebaseJson: _firebaseJson ?? <String, dynamic>{},
              iOS: _ios,
              android: _android,
              web: _web,
              windows: _windows,
              macos: _macos,
              linux: _linux,
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

          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            snackBarTile(
              context,
              _result,
              type: SnackBarType.error,
            ),
          );
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
          setState(() {
            _currentActivity = null;
            _index = _NewProjectSections
                .values[_NewProjectSections.values.length - 2];
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: DialogTemplate(
        outerTapExit: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DialogHeader(
              leading: _index != _NewProjectSections.projectName &&
                      _index != _NewProjectSections.creatingProject
                  ? SquareButton(
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: customTheme.textTheme.bodyText1!.color,
                      ),
                      color: Colors.transparent,
                      onPressed: () => setState(() => _index =
                          _NewProjectSections.values[_index.index - 1]),
                    )
                  : null,
              title: 'New Project',
              canClose: _index != _NewProjectSections.creatingProject,
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
                  // Project Description
                  if (_index == _NewProjectSections.projectDescription)
                    ProjectDescriptionSection(
                        controller: _descriptionController),
                  // Project Org Name
                  if (_index == _NewProjectSections.projectOrgName)
                    ProjectOrgNameSection(
                      projName: _nameController.text,
                      controller: _orgController,
                    ),
                  // Project Platforms
                  if (_index == _NewProjectSections.projectPlatforms)
                    ProjectPlatformsSection(
                      ios: _ios,
                      android: _android,
                      windows: _windows,
                      macos: _macos,
                      linux: _linux,
                      web: _web,
                      onChanged: ({
                        bool ios = true,
                        bool android = true,
                        bool web = true,
                        bool windows = true,
                        bool macos = true,
                        bool linux = true,
                        bool isNullSafety = true,
                      }) {
                        setState(() {
                          _ios = ios;
                          _android = android;
                          _web = web;
                          _windows = windows;
                          _macos = macos;
                          _linux = linux;
                        });
                      },
                    ),
                  if (_index == _NewProjectSections.preConfigProject)
                    ProjectPreConfigSection(
                      firebaseJson: _firebaseJson,
                      onFirebaseUpload: (Map<String, dynamic>? json) {
                        setState(() => _firebaseJson = json);
                      },
                    ),
                ],
              ),
            ),
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
                    Text(
                      _currentActivity ??
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
                      style: TextStyle(
                        color: customTheme.textTheme.bodyText1!.color,
                      ),
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
  projectDescription,
  projectOrgName,
  projectPlatforms,
  preConfigProject,
  creatingProject,
}

class ProjectCreatedDialog extends StatelessWidget {
  final String projectName;
  final String projectPath;

  const ProjectCreatedDialog({
    Key? key,
    required this.projectName,
    required this.projectPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const DialogHeader(title: 'Project Created'),
          const Text(
              'Your new project has successfully been created. You should be able to open your project and run it!',
              textAlign: TextAlign.center),
          VSeparators.large(),
          infoWidget(context,
              'If you are new here, take some time to read the documentation and how you can automate some workflows you do day to day in your Flutter environment.'),
          VSeparators.large(),
          Row(
            children: <Widget>[
              Expanded(
                child: RectangleButton(
                  width: double.infinity,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      snackBarTile(
                        context,
                        'You can still find your project in the Projects tab.',
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ),
              HSeparators.small(),
              Expanded(
                child: RectangleButton(
                  width: double.infinity,
                  onPressed: () async {
                    Navigator.pop(context);
                    await showDialog(
                      context: context,
                      builder: (_) => OpenProjectOnEditor(path: projectPath),
                    );
                  },
                  child: const Text('Open in Editor'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
