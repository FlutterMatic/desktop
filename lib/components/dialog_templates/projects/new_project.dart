import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_installer/components/dialog_templates/dialog_header.dart';
import 'package:flutter_installer/components/widgets/check_box_element.dart';
import 'package:flutter_installer/components/widgets/dialog_template.dart';
import 'package:flutter_installer/components/widgets/info_widget.dart';
import 'package:flutter_installer/components/widgets/rectangle_button.dart';
import 'package:flutter_installer/components/widgets/square_button.dart';
import 'package:flutter_installer/components/widgets/text_field.dart';
import 'package:flutter_installer/components/widgets/warning_widget.dart';
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
  // ignore: unused_field
  String? _projectDescription;
  String? _projectOrg;

  //Utils
  int _index = 0;

  final _createProjectFormKey = GlobalKey<FormState>();
  final TextEditingController _pNameController = TextEditingController();
  final TextEditingController _pDescController = TextEditingController();
  final TextEditingController _pOrgController = TextEditingController();

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

  bool _validatePlatformSelection() => !(_ios == false &&
      _android == false &&
      _web == false &&
      _windows == false &&
      _macos == false &&
      _linux == false);

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
      else if (_index == 3 && _validatePlatformSelection()) {
        setState(() => _index = 4);
        try {
          await flutterActions.flutterCreate(
            _projectName!,
            _projectDescription!,
            _projectOrg!,
            android: _android,
            windows: _windows,
            ios: _ios,
            macos: _macos,
            linux: _linux,
            web: _web,
          );
          //Success
          await flutterActions.checkProjects();
          Navigator.pop(context);
          await showDialog(
              context: context,
              builder: (_) => ProjectCreatedDialog(projectName: _projectName!));
        } catch (_) {
          //Failed
          await showDialog(
              context: context, builder: (_) => CreateProjectErrorDialog());
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
                //Index 0
                if (_index == 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CustomTextField(
                        controller: _pNameController,
                        autofocus: true,
                        hintText: 'Project Name',
                        filteringTextInputFormatter:
                            FilteringTextInputFormatter.allow(
                          RegExp('[a-zA-Z-_0-9 ]'),
                        ),
                        onChanged: (val) => setState(
                          () => _projectName =
                              val.trim().replaceAll(RegExp(r'-| '), '_'),
                        ),
                        validator: (val) => val!.isEmpty
                            ? 'Enter project name'
                            : val.length < 3
                                ? 'Too short, try adding some more'
                                : null,
                        maxLength: 70,
                      ),
                      const SizedBox(height: 10),
                      //Checks if name doesn't start with a lower-case letter
                      if (_projectName != null &&
                          !_projectName!.startsWith(RegExp('[a-zA-Z]')))
                        warningWidget(
                          'Your project name needs to start with a lower-case English character (a-z).',
                          Assets.error,
                          kRedColor,
                        ),
                      //Checks if there are numbers included in the project name
                      if (_projectName != null &&
                          _projectName!.contains(RegExp('[0-9]')))
                        warningWidget(
                          'You can\'t have any numbers in your project name. Try using characters such as English letters (a-z) and underscores (_).',
                          Assets.error,
                          kRedColor,
                        ),
                      //Checks to see if there are any upper-case letters
                      if (_projectName != null &&
                          _projectName!.contains(RegExp(r'[A-Z]')))
                        warningWidget(
                          'Any upper-case letters in the project name will be turned to a lower-case letter.',
                          Assets.warning,
                          kYellowColor,
                        ),
                      //Checks to see if lower-case letter is started with
                      if (_projectName != null &&
                          _projectName!.startsWith(RegExp('[a-zA-Z]')) &&
                          !_projectName!.contains(RegExp('[0-9]')))
                        warningWidget(
                          'Your new project will be called "${_projectName!.trim().replaceAll(RegExp(r'-| '), '_').toLowerCase()}"',
                          Assets.done,
                          kGreenColor,
                        ),
                      infoWidget(
                          'Your project name can only include lower-case English letters (a-z) and underscores (_).')
                    ],
                  ),
                //Index 1
                if (_index == 1)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CustomTextField(
                        controller: _pDescController,
                        filteringTextInputFormatter:
                            FilteringTextInputFormatter.allow(
                          RegExp('[a-zA-Z0-9\.\,\\s]'),
                        ),
                        numLines: 4,
                        hintText: 'Description',
                        validator: (String? _pDesc) => _pDesc!.isEmpty
                            ? 'Please enter project description'
                            : null,
                        maxLength: 150,
                        onChanged: (val) => setState(() =>
                            _projectDescription = val.isEmpty ? null : val),
                      ),
                      infoWidget(
                        'The description will be added as description in the pubspec.yaml file of your new project.',
                      ),
                    ],
                  ),
                //Index 2
                if (_index == 2)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CustomTextField(
                        controller: _pOrgController,
                        filteringTextInputFormatter:
                            FilteringTextInputFormatter.allow(
                          RegExp('[a-zA-Z\_\.]'),
                        ),
                        hintText:
                            'Project Organization (com.example.$_projectName)',
                        validator: (val) => val!.isEmpty
                            ? 'Please enter project organization'
                            : val.length > 30
                                ? 'Organization name is too long. Try (com.example.$_projectName)'
                                : null,
                        maxLength: 30,
                        onChanged: (val) => setState(() {
                          if (val.isNotEmpty) {
                            _projectOrg = val;
                          } else {
                            _projectOrg = null;
                          }
                        }),
                      ),
                      if (_projectOrg != null &&
                          _projectOrg!.contains('.') &&
                          _projectOrg!.contains(RegExp('[A-Za-z_]')) &&
                          !_projectOrg!.endsWith('.') &&
                          !_projectOrg!.endsWith('_') &&
                          '.'.allMatches(_projectOrg!).length < 3)
                        warningWidget(
                            '"$_projectOrg.$_projectName" will be your organization name. You can change it later.',
                            Assets.done,
                            kGreenColor),
                      if (_projectOrg != null &&
                          (_projectOrg!.endsWith('_') ||
                              _projectOrg!.endsWith('.') ||
                              !_projectOrg!.contains('.')) &&
                          '.'.allMatches(_projectOrg!).length < 3)
                        warningWidget(
                          'Invalid organization name. Make sure it doesn\'t end with "." or "_" and that it matches something like "com.example.app"',
                          Assets.error,
                          kRedColor,
                        ),
                      if (_projectOrg != null &&
                          '.'.allMatches(_projectOrg!).length > 2)
                        warningWidget(
                          'Please check your organization name. This doesn\'t seem to be a proper one. Try something like com.$_projectName.app',
                          Assets.error,
                          kRedColor,
                        ),
                      infoWidget(
                          'The organization responsible for your new Flutter project, in reverse domain name notation. This string is used in Java package names and as prefix in the iOS bundle identifier.'),
                    ],
                  ),
              ],
            ),
          ),
          if (_index == 3)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                    'Choose which enviroments you want to enable for your new Flutter project.'),
                const SizedBox(height: 10),
                CheckBoxElement(
                  onChanged: (val) => setState(() => _ios = !_ios),
                  value: _ios,
                  text: 'iOS',
                ),
                CheckBoxElement(
                  onChanged: (val) => setState(() => _android = !_android),
                  value: _android,
                  text: 'Android',
                ),
                CheckBoxElement(
                  onChanged: (val) => setState(() => _web = !_web),
                  value: _web,
                  text: 'Web',
                ),
                CheckBoxElement(
                  onChanged: (val) => setState(() => _windows = !_windows),
                  value: _windows,
                  text: 'Windows',
                ),
                CheckBoxElement(
                  onChanged: (val) => setState(() => _macos = !_macos),
                  value: _macos,
                  text: 'MacOS',
                ),
                CheckBoxElement(
                  onChanged: (val) => setState(() => _linux = !_linux),
                  value: _linux,
                  text: 'Linux',
                ),
                if (!_validatePlatformSelection())
                  warningWidget(
                    'You will need to choose at least one platform. You will be able to change it later.',
                    Assets.error,
                    kRedColor,
                  ),
              ],
            ),
          if (_index == 4)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 30),
                const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                    'Creating your new Flutter project. This may take a while.'),
              ],
            ),
          const SizedBox(height: 10),
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

class CreateProjectErrorDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          DialogHeader(title: 'Unable to Create Project'),
          const SizedBox(height: 20),
          const Text(
            'We were unable to create a new project for some reason. Please try again. If this issue continues to happen, then please create a new issue on GitHub.',
            textAlign: TextAlign.center,
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
            child: const Text('OK'),
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
