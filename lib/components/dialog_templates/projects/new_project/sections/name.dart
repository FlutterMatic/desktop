import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manager/core/libraries/widgets.dart';

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
          informationWidget(
            'Your project name needs to start with a lower-case English character (a-z).',
            type: InformationType.ERROR,
          ),
        //Checks if there are numbers included in the project name
        if (_projectName != null && _projectName!.contains(RegExp('[0-9]')))
          informationWidget(
            'You can\'t have any numbers in your project name. Try using characters such as English letters (a-z) and underscores (_).',
            type: InformationType.ERROR,
          ),
        //Checks to see if there are any upper-case letters
        if (_projectName != null && _projectName!.contains(RegExp(r'[A-Z]')))
          informationWidget(
            'Any upper-case letters in the project name will be turned to a lower-case letter.',
            type: InformationType.WARNING,
          ),
        //Checks to see if lower-case letter is started with
        if (_projectName != null &&
            _projectName!.startsWith(RegExp('[a-zA-Z]')) &&
            !_projectName!.contains(RegExp('[0-9]')))
          informationWidget(
            'Your new project will be called "${_projectName!.trim().replaceAll(RegExp(r'-| '), '_').toLowerCase()}"',
            type: InformationType.GREEN,
          ),
        infoWidget(context,
            'Your project name can only include lower-case English letters (a-z) and underscores (_).')
      ],
    );
  }
}
