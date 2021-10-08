// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🌎 Project imports:
import 'package:manager/core/libraries/widgets.dart';

class ProjectOrgNameSection extends StatefulWidget {
  final String projName;
  final Function(String? val) onChanged;

  const ProjectOrgNameSection(
      {Key? key, required this.projName, required this.onChanged})
      : super(key: key);

  @override
  _ProjectOrgNameSectionState createState() => _ProjectOrgNameSectionState();
}

class _ProjectOrgNameSectionState extends State<ProjectOrgNameSection> {
  final TextEditingController _pOrgController = TextEditingController();

  String? _projectOrg;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CustomTextField(
          autofocus: true,
          controller: _pOrgController,
          filteringTextInputFormatter: FilteringTextInputFormatter.allow(
            RegExp('[a-zA-Z_.]'),
          ),
          hintText: 'Project Organization (com.example.${widget.projName})',
          validator: (String? val) => val!.isEmpty
              ? 'Please enter project organization'
              : val.length > 30
                  ? 'Organization name is too long. Try (com.example.${widget.projName})'
                  : null,
          maxLength: 30,
          onChanged: (String val) {
            setState(() {
              if (val.isEmpty) {
                _projectOrg = null;
              } else if ('.'.allMatches(_projectOrg ?? '').length == 1) {
                _projectOrg = val + '.${widget.projName}';
              } else {
                _projectOrg = val;
              }
            });
            widget.onChanged(val);
          },
        ),
        if (_projectOrg != null &&
            _projectOrg!.contains('.') &&
            _projectOrg!.contains(RegExp('[A-Za-z_]')) &&
            !_projectOrg!.endsWith('.') &&
            !_projectOrg!.endsWith('_') &&
            '.'.allMatches(_projectOrg!).length < 3)
          informationWidget(
            '"${'.'.allMatches(_projectOrg ?? '').length == 1 ? '$_projectOrg.${widget.projName}' : _projectOrg}" will be your organization name. You can change it later.',
            type: InformationType.green,
          ),
        if (_projectOrg != null &&
            (_projectOrg!.endsWith('_') ||
                _projectOrg!.endsWith('.') ||
                !_projectOrg!.contains('.')) &&
            '.'.allMatches(_projectOrg!).length < 3)
          informationWidget(
            'Invalid organization name. Make sure it doesn\'t end with "." or "_" and that it matches something like "com.example.app"',
            type: InformationType.warning,
          ),
        if (_projectOrg != null && '.'.allMatches(_projectOrg!).length > 2)
          informationWidget(
            'Please check your organization name. This doesn\'t seem to be a proper one. Try something like com.${widget.projName}.app',
            type: InformationType.error,
          ),
        infoWidget(context,
            'The organization responsible for your new Flutter project, in reverse domain name notation. This string is used in Java package names and as prefix in the iOS bundle identifier.'),
      ],
    );
  }
}
