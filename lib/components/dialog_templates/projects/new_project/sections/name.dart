import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/inputs/text_field.dart';
import 'package:manager/components/widgets/ui/info_widget.dart';
import 'package:manager/components/widgets/ui/warning_widget.dart';

class ProjectNameSection extends StatefulWidget {
  final Function(String? val) onChanged;

  ProjectNameSection({required this.onChanged});

  @override
  _ProjectNameSectionState createState() => _ProjectNameSectionState();
}

class _ProjectNameSectionState extends State<ProjectNameSection> {
  final TextEditingController _pNameController = TextEditingController();

  String? _projectName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CustomTextField(
          controller: _pNameController,
          autofocus: true,
          hintText: 'Project Name',
          filteringTextInputFormatter: FilteringTextInputFormatter.allow(
            RegExp('[a-zA-Z-_0-9 ]'),
          ),
          onChanged: (String val) {
            setState(
              () {
                if (val.isNotEmpty) {
                  _projectName = val.trim().replaceAll(RegExp(r'-| '), '_');
                } else {
                  _projectName = null;
                }
              },
            );
            widget.onChanged(_projectName);
          },
          validator: (String? val) => val!.isEmpty
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
        if (_projectName != null && _projectName!.contains(RegExp('[0-9]')))
          warningWidget(
            'You can\'t have any numbers in your project name. Try using characters such as English letters (a-z) and underscores (_).',
            Assets.error,
            kRedColor,
          ),
        //Checks to see if there are any upper-case letters
        if (_projectName != null && _projectName!.contains(RegExp(r'[A-Z]')))
          warningWidget(
            'Any upper-case letters in the project name will be turned to a lower-case letter.',
            Assets.warn,
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
        infoWidget(context,
            'Your project name can only include lower-case English letters (a-z) and underscores (_).')
      ],
    );
  }
}
