// 🎯 Dart imports:
import 'dart:developer';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/components/dialog_templates/projects/new_project/sections/dart_config.dart';
import 'package:manager/components/dialog_templates/projects/new_project/sections/description.dart';
import 'package:manager/components/dialog_templates/projects/new_project/sections/name.dart';
import 'package:manager/components/dialog_templates/projects/new_project/sections/org_name.dart';
import 'package:manager/components/dialog_templates/projects/new_project/sections/platforms.dart';
import 'package:manager/components/dialog_templates/projects/new_project/sections/pre_config.dart';
import 'package:manager/core/libraries/widgets.dart';

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

  bool _validateOrgName() =>
      _orgController.text != '' &&
      _orgController.text.contains('.') &&
      _orgController.text.contains(RegExp('[A-Za-z_]')) &&
      !_orgController.text.endsWith('.') &&
      !_orgController.text.endsWith('_');

  // Dart & Flutter Config
  bool _isNullSafety = true;

  Future<void> _createNewProject() async {
    if (_createProjectFormKey.currentState!.validate()) {
      // Name
      if (_index == _NewProjectSections.projectName &&
          _projectNameCondition()) {
        setState(
            () => _nameController.text = _nameController.text.toLowerCase());
        setState(() => _index = _NewProjectSections.projectDescription);
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
          setState(() => _index = _NewProjectSections.projectDartConfig);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            snackBarTile(
              context,
              'Please select appropriate platforms.',
              type: SnackBarType.error,
              revert: true,
            ),
          );
        }
      }
      // Pre configure
      else if (_index == _NewProjectSections.projectDartConfig) {
        setState(() => _index = _NewProjectSections.preConfigProject);
      }
      // Creating project page.
      else if (_index == _NewProjectSections.preConfigProject) {
        try {
          // TODO: Create a new Flutter project based on the user input.
          BgActivityTile _activityElement = BgActivityTile(
            title: 'Creating new Flutter project',
            activityId: Timeline.now.toString(),
          );
          bgActivities.add(_activityElement);
          bgActivities.remove(_activityElement);
          await showDialog(
            context: context,
            builder: (_) =>
                ProjectCreatedDialog(projectName: _nameController.text),
          );
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            snackBarTile(
              context,
              'Failed to create project. Please file an issue.',
              type: SnackBarType.error,
            ),
          );
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return DialogTemplate(
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
                    onPressed: () => setState(() =>
                        _index = _NewProjectSections.values[_index.index - 1]),
                  )
                : null,
            title: 'New Project',
          ),
          Form(
            key: _createProjectFormKey,
            child: Column(
              children: <Widget>[
                // Project Name
                if (_index == _NewProjectSections.projectName)
                  ProjectNameSection(controller: _nameController),
                // Project Description
                if (_index == _NewProjectSections.projectDescription)
                  ProjectDescriptionSection(controller: _descriptionController),
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
                if (_index == _NewProjectSections.projectDartConfig)
                  ProjectDartConfigSection(
                    isNullSafety: _isNullSafety,
                    onChanged: ({
                      bool isNullSafety = true,
                    }) {
                      setState(() {
                        _isNullSafety = isNullSafety;
                      });
                    },
                  ),
                if (_index == _NewProjectSections.preConfigProject)
                  const ProjectPreConfigSection(),
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
                  VSeparators.normal(),
                  const Text('Creating new project. Hold on tight.'),
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
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Text('Cancel'),
                  ),
                ),
                const Spacer(),
                RectangleButton(
                  radius: BorderRadius.circular(5),
                  onPressed: _createNewProject,
                  width: 120,
                  child: Text(
                    'Next',
                    style: TextStyle(
                      color: customTheme.textTheme.bodyText1!.color,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

enum _NewProjectSections {
  projectName,
  projectDescription,
  projectOrgName,
  projectPlatforms,
  projectDartConfig,
  preConfigProject,
  creatingProject,
}

class ProjectCreatedDialog extends StatelessWidget {
  final String projectName;

  const ProjectCreatedDialog({Key? key, required this.projectName})
      : super(key: key);

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
          RectangleButton(
            width: double.infinity,
            color: Colors.blueGrey,
            splashColor: Colors.blueGrey.withOpacity(0.5),
            focusColor: Colors.blueGrey.withOpacity(0.5),
            hoverColor: Colors.grey.withOpacity(0.5),
            highlightColor: Colors.blueGrey.withOpacity(0.5),
            onPressed: () async {
              // TODO: Open project in the editor.
              Navigator.pop(context);
            },
            child: const Text('Open in Preferred Editor'),
          ),
          VSeparators.small(),
          RectangleButton(
            width: double.infinity,
            color: Colors.blueGrey,
            splashColor: Colors.blueGrey.withOpacity(0.5),
            focusColor: Colors.blueGrey.withOpacity(0.5),
            hoverColor: Colors.grey.withOpacity(0.5),
            highlightColor: Colors.blueGrey.withOpacity(0.5),
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
