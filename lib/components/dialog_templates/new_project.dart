import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

//Inputs
String? _projectName;
String? _projectDescription;
String? _projectOrg;

//Utils
int _index = 0;

class _NewProjectDialogState extends State<NewProjectDialog> {
  final _createProjectFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    if (mounted) {
      setState(() {
        _projectName = null;
        _projectDescription = null;
        _index = 0;
      });
    }
    super.dispose();
  }

  bool _projectNameCondition() {
    if (_projectName != null &&
        _projectName!.startsWith(RegExp('[a-z]')) &&
        !_projectName!.contains(RegExp('[0-9]'))) {
      return true;
    } else {
      return false;
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
                  ? SquareButton(
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
          if (_index == 0)
            _createProjectName(
              _createProjectFormKey,
              (val) => setState(() => _projectName = val!.isEmpty
                  ? null
                  : val.trim().replaceAll(RegExp(r'-| '), '_').toLowerCase()),
            ),
          if (_index == 1)
            _createProjectDescription(_createProjectFormKey,
                (val) => _projectDescription = val!.isEmpty ? null : val),
          if (_index == 2)
            _createProjectOrg(_createProjectFormKey,
                (val) => _projectOrg = val!.isEmpty ? null : val),
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
                radius: BorderRadius.circular(5),
                onPressed: _projectNameCondition()
                    ? () => setState(() => _index++)
                    : null,
                child: Text(
                  'Continue',
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

//Project Name
Widget _createProjectName(Key key, Function(String?) onChangeds) {
  return Form(
    key: key,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          hintText: 'Project Name',
          filteringTextInputFormatter:
              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z-_0-9 ]')),
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
              kRedColor),
        //Checks if there are numbers included in the project name
        if (_projectName != null && _projectName!.contains(RegExp('[0-9]')))
          warningWidget(
              'You can\'t have any numbers in your project name. Try using characters such as English letters (a-z) and underscores (_).',
              Assets.error,
              kRedColor),
        //Checks to see if there are any upper-case letters
        if (_projectName != null && _projectName!.contains(RegExp('[A-Z]')))
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
  );
}

//Project Description
Widget _createProjectDescription(Key key, Function(String?) onChanged) {
  return Form(
    key: key,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          numLines: 4,
          hintText: 'Description',
          validator: (val) =>
              val!.isEmpty ? 'Please enter project description' : null,
          maxLength: 150,
          onChanged: onChanged,
        ),
        const SizedBox(height: 10),
      ],
    ),
  );
}

//Project Organization
Widget _createProjectOrg(Key key, Function(String?) onChanged) {
  return Form(
    key: key,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          hintText: 'Project Organization (com.example.$_projectName)',
          validator: (val) =>
              val!.isEmpty ? 'Please enter project organization' : null,
          maxLength: 30,
          onChanged: onChanged,
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
                        'The organization responsible for your new Flutter project, in reverse domain name notation. This string is used in Java package names and as prefix in the iOS bundle identifier.')),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
