import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_installer/components/dialog_template.dart';
import 'package:flutter_installer/components/rectangle_button.dart';
import 'package:flutter_installer/components/round_container.dart';
import 'package:flutter_installer/components/square_button.dart';
import 'package:flutter_installer/components/text_field.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NewProjectDialog extends StatefulWidget {
  @override
  _NewProjectDialogState createState() => _NewProjectDialogState();
}

String? _projectName;

class _NewProjectDialogState extends State<NewProjectDialog> {
  @override
  void dispose() {
    setState(() => _projectName = null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Create New Project', style: TextStyle(fontSize: 20)),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: SquareButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          CustomTextField(
            hintText: 'Project Name',
            autoFocus: true,
            filteringTextInputFormatter:
                FilteringTextInputFormatter.allow(RegExp('[a-zA-Z-_0-9 ]')),
            validator: (val) => val!.isEmpty
                ? 'Enter project name'
                : val.length < 3
                    ? 'Too short, try adding some more'
                    : null,
            maxLength: 70,
            onChanged: (val) =>
                setState(() => _projectName = val.isEmpty ? null : val),
          ),
          const SizedBox(height: 10),
          //Checks if name doesn't start with a lower-case letter
          if (_projectName != null &&
              !_projectName!.startsWith(RegExp('[a-z]')))
            _projectWarningWidget(
                'Your project name needs to start with a lower-case English character (a-z).',
                Assets.error,
                kRedColor),
          //Checks if there are numbers included in the project name
          if (_projectName != null && _projectName!.contains(RegExp('[0-9]')))
            _projectWarningWidget(
                'You can\'t have any numbers in your project name. Try using characters such as English letters (a-z) and underscores (_).',
                Assets.error,
                kRedColor),
          //Checks to see if there are any upper-case letters
          if (_projectName != null && _projectName!.contains(RegExp('[A-Z]')))
            _projectWarningWidget(
                'Any upper-case letters in the project name will be turned to a lower-case letter.',
                Assets.warning,
                kYellowColor),
          //Checks to see if lower-case letter is started with
          if (_projectName != null &&
              _projectName!.startsWith(RegExp('[a-z]')) &&
              !_projectName!.contains(RegExp('[0-9]')))
            _projectWarningWidget(
                'Your new project will be called "${_projectName!.trim().replaceAll(RegExp(r'-| '), '_').toLowerCase()}"',
                Assets.done,
                kGreenColor),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: RoundContainer(
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
                color: Colors.blue,
               
                onPressed: () {},
                child: const Text(
                  'Continue',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _projectWarningWidget(String text, String asset, Color color) {
  return Padding(
    padding: const EdgeInsets.only(top: 10),
    child: RoundContainer(
      color: color.withOpacity(0.2),
      borderColor: color,
      radius: 5,
      child: Row(
        children: [
          SvgPicture.asset(asset, height: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    ),
  );
}
