import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_installer/components/check_box_element.dart';
import 'package:flutter_installer/components/dialog_template.dart';
import 'package:flutter_installer/components/rectangle_button.dart';
import 'package:flutter_installer/components/round_container.dart';
import 'package:flutter_installer/components/square_button.dart';
import 'package:flutter_installer/components/text_field.dart';
import 'package:flutter_installer/components/warning_widget.dart';
import 'package:flutter_installer/utils/constants.dart';

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
  bool _loading = false;
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

  bool _validatePlatformSelection() => _ios == false &&
          _android == false &&
          _web == false &&
          _windows == false &&
          _macos == false &&
          _linux == false
      ? false
      : true;

  void _createNewProject() {
    //Index 0 - Name
    if (_createProjectFormKey.currentState!.validate()) {
      if (_index == 0 && _projectNameCondition()) {
        setState(() {
          _projectName = _projectName!.toLowerCase();
          _index = 1;
        });
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
        setState(() => _loading = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _index != 0
                  ? _loading
                      ? const SizedBox(width: 40)
                      : SquareButton(
                          icon: const Icon(Icons.arrow_back_ios_rounded),
                          tooltip: 'Back',
                          onPressed: () => setState(() => _index--),
                        )
                  : const SizedBox(width: 40),
              const Expanded(
                  child: Center(
                child:
                    Text('Create New Project', style: TextStyle(fontSize: 20)),
              )),
              SquareButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Close',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Form(
            key: _createProjectFormKey,
            child: Column(
              children: [
                //Index 0
                if (_index == 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        hintText: 'Project Name',
                        filteringTextInputFormatter:
                            FilteringTextInputFormatter.allow(
                                RegExp('[a-zA-Z-_0-9 ]')),
                        onChanged: (val) => setState(() => _projectName =
                            val.isEmpty
                                ? null
                                : val.trim().replaceAll(RegExp(r'-| '), '_')),
                        validator: (val) => val!.isEmpty
                            ? 'Enter project name'
                            : val.length < 3
                                ? 'Too short, try adding some more'
                                : null,
                        maxLength: 70,
                        controller: _pNameController,
                      ),
                      const SizedBox(height: 10),
                      //Checks if name doesn't start with a lower-case letter
                      if (_projectName != null &&
                          !_projectName!.startsWith(RegExp('[a-zA-Z]')))
                        warningWidget(
                            'Your project name needs to start with a lower-case English character (a-z).',
                            Assets.error,
                            kRedColor),
                      //Checks if there are numbers included in the project name
                      if (_projectName != null &&
                          _projectName!.contains(RegExp('[0-9]')))
                        warningWidget(
                            'You can\'t have any numbers in your project name. Try using characters such as English letters (a-z) and underscores (_).',
                            Assets.error,
                            kRedColor),
                      //Checks to see if there are any upper-case letters
                      if (_projectName != null &&
                          _projectName!.contains(RegExp(r'[A-Z]')))
                        warningWidget(
                            'Any upper-case letters in the project name will be turned to a lower-case letter.',
                            Assets.warning,
                            kYellowColor),
                      //Checks to see if lower-case letter is started with
                      if (_projectName != null &&
                          _projectName!.startsWith(RegExp('[a-zA-Z]')) &&
                          !_projectName!.contains(RegExp('[0-9]')))
                        warningWidget(
                            'Your new project will be called "${_projectName!.trim().replaceAll(RegExp(r'-| '), '_').toLowerCase()}"',
                            Assets.done,
                            kGreenColor),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: RoundContainer(
                          color: Colors.blueGrey.withOpacity(0.2),
                          radius: 5,
                          child: Row(
                            children: [
                              const Icon(Icons.info),
                              const SizedBox(width: 8),
                              const Expanded(
                                  child: Text(
                                      'Your project name can only include lower-case English letters (a-z) and underscores (_).')),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                //Index 1
                if (_index == 1)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        numLines: 4,
                        hintText: 'Description',
                        validator: (val) => val!.isEmpty
                            ? 'Please enter project description'
                            : null,
                        maxLength: 150,
                        onChanged: (val) =>
                            _projectDescription = val.isEmpty ? null : val,
                        controller: _pDescController,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: RoundContainer(
                          color: Colors.blueGrey.withOpacity(0.2),
                          radius: 5,
                          child: Row(
                            children: [
                              const Icon(Icons.info),
                              const SizedBox(width: 8),
                              const Expanded(
                                  child: Text(
                                      'The description will be added in the READ.md file for your new project.')),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                //Index 2
                if (_index == 2)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        hintText:
                            'Project Organization (com.example.$_projectName)',
                        validator: (val) => val!.isEmpty
                            ? 'Please enter project organization name'
                            : (val.contains('.') &&
                                    val.contains(RegExp('[A-Za-z_]')) &&
                                    val.contains('.'))
                                ? null
                                : 'Invalid organization name. Try "com.example.$_projectName"',
                        filteringTextInputFormatter:
                            FilteringTextInputFormatter.allow(
                                RegExp('[a-zA-Z._]')),
                        maxLength: 30,
                        onChanged: (val) => setState(
                            () => _projectOrg = val.isEmpty ? null : val),
                        controller: _pOrgController,
                      ),
                      if (_projectOrg != null &&
                          _projectOrg!.contains('.') &&
                          _projectOrg!.contains(RegExp('[A-Za-z_]')) &&
                          !_projectOrg!.endsWith('.') &&
                          !_projectOrg!.endsWith('_'))
                        warningWidget(
                            '"$_projectOrg" will be your organization name. You can change it later.',
                            Assets.done,
                            kGreenColor)
                      else if (_projectOrg != null)
                        warningWidget(
                            'Invalid organization name. Make sure it doesn\'t end with "." or "_" and that it matches something like "com.example.app".',
                            Assets.error,
                            kRedColor),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: RoundContainer(
                          color: Colors.blueGrey.withOpacity(0.2),
                          radius: 5,
                          child: Row(
                            children: [
                              const Icon(Icons.info),
                              const SizedBox(width: 8),
                              const Expanded(
                                  child: Text(
                                      'The organization responsible for your new Flutter project, in reverse domain name notation. This string is used in Java package names and as prefix in the iOS bundle identifier.')),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (_index == 3)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              ],
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Text('Cancel'),
                ),
              ),
              const Spacer(),
              RectangleButton(
                loading: _loading,
                radius: BorderRadius.circular(5),
                onPressed: _createNewProject,
                child: Text(
                  'Next',
                  style:
                      TextStyle(color: customTheme.textTheme.bodyText1!.color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
