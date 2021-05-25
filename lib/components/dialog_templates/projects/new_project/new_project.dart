import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/dialog_header.dart';
import 'package:flutter_installer/components/dialog_templates/projects/new_project/sections/description.dart';
import 'package:flutter_installer/components/dialog_templates/projects/new_project/sections/name.dart';
import 'package:flutter_installer/components/dialog_templates/projects/new_project/sections/org_name.dart';
import 'package:flutter_installer/components/dialog_templates/projects/new_project/sections/platforms.dart';
import 'package:flutter_installer/components/widgets/ui/dialog_template.dart';
import 'package:flutter_installer/components/widgets/buttons/rectangle_button.dart';
import 'package:flutter_installer/components/widgets/buttons/square_button.dart';
import 'package:flutter_installer/components/widgets/ui/snackbar_tile.dart';
import 'package:flutter_installer/components/widgets/ui/spinner.dart';
import 'package:flutter_installer/services/flutter_actions.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'package:process_run/shell_run.dart';

class NewProjectDialog extends StatefulWidget {
  @override
  _NewProjectDialogState createState() => _NewProjectDialogState();
}

class _NewProjectDialogState extends State<NewProjectDialog> {
  //Inputs
  String? _projectName;
  String? _projectDescription;
  String? _projectOrg;

  //Utils
  int _index = 0;

  final _createProjectFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    if (mounted) {
      _projectName = null;
      _projectDescription = null;
      _index = 0;
    }
    super.dispose();
  }

  //Platforms
  bool _ios = true;
  bool _android = true;
  bool _web = true;
  bool _windows = true;
  bool _macos = true;
  bool _linux = true;

  bool _projectNameCondition() =>
      _projectName != null &&
      _projectName!.startsWith(RegExp('[a-zA-Z]')) &&
      !_projectName!.contains(RegExp('[0-9]'));

  bool _validateOrgName() =>
      _projectOrg != null &&
      _projectOrg!.contains('.') &&
      _projectOrg!.contains(RegExp('[A-Za-z_]')) &&
      !_projectOrg!.endsWith('.') &&
      !_projectOrg!.endsWith('_');

  Future<void> _createNewProject() async {
    if (_createProjectFormKey.currentState!.validate()) {
      //Index 0 - Name
      if (_index == 0 && _projectNameCondition()) {
        setState(() => _projectName = _projectName!.toLowerCase());
        setState(() => _index = 1);
      }
      // Index 1 - Description
      else if (_index == 1) {
        setState(() => _index = 2);
      }
      // Index 2 - Org Name
      else if (_index == 2 && _validateOrgName()) {
        setState(() => _index = 3);
      }
      // Index 3 - Platforms
      else if (_index == 3 &&
          validatePlatformSelection(
            ios: _ios,
            android: _android,
            web: _web,
            windows: _windows,
            macos: _macos,
            linux: _linux,
          )) {
        setState(() => _index = 4);
        try {
          await FlutterActions().flutterCreate(
            _projectName!,
            _projectDescription!,
            _projectOrg!,
            ios: _ios,
            android: _android,
            web: _web,
            windows: _windows,
            macos: _macos,
            linux: _linux,
          );
          //Success
          await FlutterActions().checkProjects();
          Navigator.pop(context);
          await showDialog(
              context: context,
              builder: (_) => ProjectCreatedDialog(projectName: _projectName!));
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
              'Failed to create project. Please file an issue.',
              type: SnackBarType.error));
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
            leading: _index != 0 && _index != 4
                ? SquareButton(
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: customTheme.textTheme.bodyText1!.color,
                    ),
                    color: customTheme.buttonColor,
                    hoverColor: customTheme.accentColor,
                    onPressed: () => setState(() => _index--),
                  )
                : null,
            title: 'Create New Project',
          ),
          const SizedBox(height: 20),
          Form(
            key: _createProjectFormKey,
            child: Column(
              children: <Widget>[
                // Project Name
                if (_index == 0)
                  ProjectNameSection(
                    onChanged: (val) => setState(() => _projectName = val),
                  ),
                // Project Description
                if (_index == 1)
                  ProjectDescriptionSection(
                    onChagned: (val) =>
                        setState(() => _projectDescription = val),
                  ),
                // Project Org Name
                if (_index == 2)
                  ProjectOrgNameSection(
                    projName: _projectName!,
                    onChanged: (val) => setState(() => _projectOrg = val),
                  ),
              ],
            ),
          ),
          // Project Platforms
          if (_index == 3)
            ProjectPlatformsSection(
              onChanged: (bool ios, bool android, bool web, bool windows,
                  bool macos, bool linux) {
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
          // Creating Project Indicator
          if (_index == 4)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 30),
                Center(child: Spinner(thickness: 3)),
                const SizedBox(height: 30),
                const Text(
                  'Creating your new Flutter project. This may take a while.',
                ),
              ],
            ),
          const SizedBox(height: 10),
          // Cancel & Next Buttons
          if (_index != 4)
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

class ProjectCreatedDialog extends StatelessWidget {
  final String projectName;

  ProjectCreatedDialog({required this.projectName});
  final Shell _shell = Shell(verbose: false);

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          DialogHeader(title: 'Project Created'),
          const SizedBox(height: 20),
          const Text(
              'Your new project has successfully been created. You should be able to open your project and run it!',
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          RectangleButton(
            width: double.infinity,
            color: Colors.blueGrey,
            splashColor: Colors.blueGrey.withOpacity(0.5),
            focusColor: Colors.blueGrey.withOpacity(0.5),
            hoverColor: Colors.grey.withOpacity(0.5),
            highlightColor: Colors.blueGrey.withOpacity(0.5),
            onPressed: () async {
              await _shell.run('code $projDir\\$projectName');
              Navigator.pop(context);
            },
            child: const Text('Open in Preferred Editor'),
          ),
          const SizedBox(height: 10),
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
