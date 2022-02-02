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
import 'package:fluttermatic/components/dialog_templates/project/flutter/sections/description.dart';
import 'package:fluttermatic/components/dialog_templates/project/flutter/sections/org_name.dart';
import 'package:fluttermatic/components/dialog_templates/project/flutter/sections/platforms.dart';
import 'package:fluttermatic/components/dialog_templates/project/flutter/sections/pre_config.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/load_activity_msg.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/core/services/actions/flutter.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/bin/project_pre_configs/firebase.dart';
import 'package:fluttermatic/meta/utils/bin/project_pre_configs/response.dart';
import 'package:fluttermatic/meta/utils/shared_pref.dart';

class NewFlutterProjectDialog extends StatefulWidget {
  const NewFlutterProjectDialog({Key? key}) : super(key: key);

  @override
  _NewFlutterProjectDialogState createState() =>
      _NewFlutterProjectDialogState();
}

class _NewFlutterProjectDialogState extends State<NewFlutterProjectDialog> {
  // Input Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _orgController = TextEditingController();

  // Utils
  _NewProjectSections _index = _NewProjectSections.projectName;
  String _currentActivity = '';

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

  // Firebase Pre-Config
  List<String> _firebasePlist = <String>[];
  List<String> _firebaseWebConfig = <String>[];
  Map<String, dynamic> _firebaseJson = <String, dynamic>{};

  bool _confirmDirectory() {
    if (_path == null) {
      return false;
    }

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
        bool _valid = _confirmDirectory();

        if (_valid) {
          setState(() {
            _nameController.text = _nameController.text.toLowerCase();
            _index = _NewProjectSections.projectDescription;
          });
        }
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
          // Make sure that this project name doesn't already exist in the
          // selected path.
          bool _valid = _confirmDirectory();

          if (_valid) {
            setState(() => _index = _NewProjectSections.creatingProject);

            NewFlutterProjectInfo _projectInfo = NewFlutterProjectInfo(
              projectPath: _path!,
              projectName: _nameController.text,
              description: _descriptionController.text,
              orgName: _orgController.text,
              firebaseJson: _firebaseJson,
              iOS: _ios,
              android: _android,
              web: _web,
              windows: _windows,
              macos: _macos,
              linux: _linux,
            );

            Future<void> _deleteProject() async {
              try {
                Directory _dir = Directory(
                    _projectInfo.projectPath + '\\' + _projectInfo.projectName);
                await _dir.delete(recursive: true);
                await logger.file(LogTypeTag.warning,
                    'Project has been deleted because of pre-config error during setup.');
              } catch (_, s) {
                await logger.file(LogTypeTag.error,
                    'Error deleting project for pre-config error: $_',
                    stackTraces: s);
              }

              setState(() {
                _index = _NewProjectSections
                    .values[_NewProjectSections.values.length - 2];
                _currentActivity = '';
              });
            }

            String _result =
                await FlutterActionServices.createNewProject(_projectInfo);

            if (_result == 'success') {
              // Add the pre-config for Firebase Android.
              if (_firebaseJson.isNotEmpty) {
                setState(() =>
                    _currentActivity = 'Adding Firebase Android pre-config...');
                PreConfigResponse _result = await FirebasePreConfig.addAndroid(
                  projectPath: _path!,
                  googleServicesJSON: _firebaseJson,
                  project: _projectInfo,
                );

                if (!_result.success) {
                  await _deleteProject();
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    snackBarTile(
                      context,
                      _result.error ?? 'Failed to add Firebase Android config.',
                      type: SnackBarType.error,
                    ),
                  );
                  return;
                }
              }

              // Add the pre-config for Firebase iOS.
              if (_firebasePlist.isNotEmpty) {
                setState(() =>
                    _currentActivity = 'Adding Firebase iOS pre-config...');
                PreConfigResponse _result = await FirebasePreConfig.addIOS(
                  projectPath: _path!,
                  googleServicesPlist: _firebasePlist,
                  project: _projectInfo,
                );

                if (!_result.success) {
                  await _deleteProject();
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    snackBarTile(
                      context,
                      _result.error ?? 'Failed to add Firebase iOS config.',
                      type: SnackBarType.error,
                    ),
                  );
                  return;
                }
              }

              // Add the pre-config for Firebase Web.
              if (_firebaseWebConfig.isNotEmpty) {
                setState(() =>
                    _currentActivity = 'Adding Firebase web pre-config...');
                PreConfigResponse _result = await FirebasePreConfig.addWeb(
                  projectPath: _path!,
                  firebaseConfig: _firebaseWebConfig,
                  project: _projectInfo,
                );

                if (!_result.success) {
                  await _deleteProject();
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    snackBarTile(
                      context,
                      _result.error ?? 'Failed to add Firebase Web config.',
                      type: SnackBarType.error,
                    ),
                  );
                  return;
                }
              }

              await FirebasePreConfig.addIOS(
                projectPath: _path!,
                googleServicesPlist: <String>[],
                project: _projectInfo,
              );

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

            setState(() {
              _index = _NewProjectSections
                  .values[_NewProjectSections.values.length - 2];
              _currentActivity = '';
            });

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
          setState(() {
            _index = _NewProjectSections
                .values[_NewProjectSections.values.length - 2];
            _currentActivity = '';
          });
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DialogHeader(
              leading: _index != _NewProjectSections.projectName &&
                      _index != _NewProjectSections.creatingProject
                  ? SquareButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                      color: Colors.transparent,
                      onPressed: () => setState(() => _index =
                          _NewProjectSections.values[_index.index - 1]),
                    )
                  : null,
              title: 'Flutter Project',
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
                    FlutterProjectDescriptionSection(
                        controller: _descriptionController),
                  // Project Org Name
                  if (_index == _NewProjectSections.projectOrgName)
                    FlutterProjectOrgNameSection(
                      projName: _nameController.text,
                      controller: _orgController,
                    ),
                  // Project Platforms
                  if (_index == _NewProjectSections.projectPlatforms)
                    FlutterProjectPlatformsSection(
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
                    FlutterProjectPreConfigSection(
                      orgName: _orgController.text,
                      firebaseJson: _firebaseJson,
                      firebasePlist: _firebasePlist,
                      firebaseWebConfig: _firebaseWebConfig,
                      onJsonUpload: (Map<String, dynamic>? json) => setState(
                          () => _firebaseJson = json ?? <String, dynamic>{}),
                      onPlistUpload: (List<String> plist) =>
                          setState(() => _firebasePlist = plist),
                      onWebConfigUpload: (List<String> webConfig) =>
                          setState(() => _firebaseWebConfig = webConfig),
                      isAndroid: _android,
                      isIos: _ios,
                      isWeb: _web,
                    ),
                ],
              ),
            ),
            // Creating Project Indicator
            if (_index == _NewProjectSections.creatingProject)
              Padding(
                padding: const EdgeInsets.all(50),
                child: LoadActivityMessageElement(message: _currentActivity),
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
  projectDescription,
  projectOrgName,
  projectPlatforms,
  preConfigProject,
  creatingProject,
}
