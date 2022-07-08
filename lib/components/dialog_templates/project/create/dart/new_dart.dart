// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/shared_pref.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/dialog_templates/project/create/add_dependencies.dart';
import 'package:fluttermatic/components/dialog_templates/project/create/common/dependencies.dart';
import 'package:fluttermatic/components/dialog_templates/project/create/common/name.dart';
import 'package:fluttermatic/components/dialog_templates/project/create/created.dart';
import 'package:fluttermatic/components/dialog_templates/project/create/dart/sections/template.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/load_activity_msg.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/core/notifiers/models/payloads/actions/dart.dart';
import 'package:fluttermatic/core/notifiers/notifiers/actions/dart.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/general/shared_pref.dart';

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

  String _currentActivity = '';

  // Dependencies and Dev Dependencies
  List<String> _dependencies = <String>[];
  List<String> _devDependencies = <String>[];

  bool _projectNameCondition() =>
      _nameController.text != '' &&
      _nameController.text.startsWith(RegExp('[a-zA-Z]')) &&
      !_nameController.text.contains(RegExp('[0-9]'));

  bool _projectPathCondition() =>
      _path != null && Directory(_path!).existsSync();

  String? _path = SharedPref().pref.getString(SPConst.projectsPath);

  bool _confirmDirectory() {
    List<FileSystemEntity> dirs = Directory(_path!).listSync();

    // Make sure that there is no directory with the same name
    for (FileSystemEntity dir in dirs) {
      String existName = dir.path.split('\\').last.toLowerCase();

      if (existName == _nameController.text.toLowerCase()) {
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

  // Future<void> _createNewProject() async {
  //   if (_createProjectFormKey.currentState!.validate()) {
  //     // Name
  //     if (_index == _NewProjectSections.projectName &&
  //         _projectNameCondition()) {
  //       if (!_projectPathCondition()) {
  //         ScaffoldMessenger.of(context).clearSnackBars();
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           snackBarTile(
  //             context,
  //             'Please select a valid path to save project to.',
  //             type: SnackBarType.error,
  //           ),
  //         );

  //         return;
  //       }

  //       // Make sure that this project name doesn't already exist in the
  //       // selected path.
  //       bool confirm = _confirmDirectory();

  //       if (confirm) {
  //         setState(() {
  //           _nameController.text = _nameController.text.toLowerCase();
  //           _index = _NewProjectSections.projectTemplate;
  //         });
  //       }
  //     } else if (_index == _NewProjectSections.projectTemplate) {
  //       setState(() => _index = _NewProjectSections.projectDependencies);
  //     } else if (_index == _NewProjectSections.projectDependencies) {
  //       try {
  //         // Make sure that this project name doesn't already exist in the
  //         // selected path.
  //         bool confirm = _confirmDirectory();

  //         if (confirm) {
  //           setState(() => _index = _NewProjectSections.creatingProject);

  //           String result = await DartActionsNotifier.createNewProject(
  //             NewDartProjectInfo(
  //               projectName: _nameController.text,
  //               projectPath: _path!,
  //               template: _template,
  //             ),
  //           );

  //           if (result == 'success') {
  //             List<String> failedDependencies = <String>[];

  //             // Add the normal dependencies to the project.
  //             if (_dependencies.isNotEmpty) {
  //               for (String dependency in _dependencies) {
  //                 setState(() => _currentActivity =
  //                     'Adding $dependency to dependencies...');

  //                 bool result = await addDependencyToProject(
  //                   path: '${_path!}\\${_nameController.text}',
  //                   dependency: dependency,
  //                   isDev: false,
  //                   isDart: true,
  //                 );

  //                 if (!result) {
  //                   failedDependencies.add(dependency);
  //                 }
  //               }
  //             }

  //             // Add the dev dependencies to the project.
  //             if (_devDependencies.isNotEmpty) {
  //               for (String dev in _devDependencies) {
  //                 setState(() =>
  //                     _currentActivity = 'Adding $dev to dev dependencies...');

  //                 bool result = await addDependencyToProject(
  //                   path: '${_path!}\\${_nameController.text}',
  //                   dependency: dev,
  //                   isDev: true,
  //                   isDart: true,
  //                 );

  //                 if (!result) {
  //                   failedDependencies.add(dev);
  //                 }
  //               }
  //             }

  //             if (failedDependencies.isNotEmpty) {
  //               await logger.file(LogTypeTag.warning,
  //                   'Created new Dart project but failed to add the following dependencies: ${failedDependencies.join(', ')}');
  //             }

  //             if (mounted) {
  //               Navigator.pop(context);
  //             }

  //             await showDialog(
  //               context: context,
  //               builder: (_) => ProjectCreatedDialog(
  //                 projectName: _nameController.text,
  //                 projectPath: '${_path!}\\${_nameController.text}',
  //               ),
  //             );

  //             return;
  //           }

  //           setState(() => _index = _NewProjectSections
  //               .values[_NewProjectSections.values.length - 2]);

  //           if (mounted) {
  //             ScaffoldMessenger.of(context).clearSnackBars();
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               snackBarTile(
  //                 context,
  //                 result,
  //                 type: SnackBarType.error,
  //               ),
  //             );
  //           }
  //         }
  //       } catch (_, s) {
  //         await logger.file(
  //             LogTypeTag.error, 'Failed to create new Flutter project: $_',
  //             stackTraces: s);

  //         if (mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             snackBarTile(
  //               context,
  //               'Failed to create project. Please file an issue.',
  //               type: SnackBarType.error,
  //             ),
  //           );
  //         }
  //         setState(() => _index = _NewProjectSections
  //             .values[_NewProjectSections.values.length - 2]);
  //       }
  //     }
  //   }
  // }

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
                  : null,
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
                  if (_index == _NewProjectSections.projectDependencies)
                    ProjectDependenciesSection(
                      dependencies: _dependencies,
                      devDependencies: _devDependencies,
                      onDependenciesChanged: (List<String> val) =>
                          setState(() => _dependencies = val),
                      onDevDependenciesChanged: (List<String> val) =>
                          setState(() => _devDependencies = val),
                    ),
                ],
              ),
            ),
            VSeparators.normal(),
            // Creating Project Indicator
            if (_index == _NewProjectSections.creatingProject)
              Padding(
                padding: const EdgeInsets.fromLTRB(80, 20, 80, 10),
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
                    // onPressed: _createNewProject, // TODO: Implement.
                    onPressed: () {},
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
  projectDependencies,
  creatingProject,
}
