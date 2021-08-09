import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/inputs/text_field.dart';
import 'package:manager/components/widgets/ui/info_widget.dart';
import 'package:manager/components/widgets/ui/warning_widget.dart';

class ProjectOrgNameSection extends StatefulWidget {
  final String projName;
  final Function(String? val) onChanged;

  ProjectOrgNameSection({required this.projName, required this.onChanged});

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
          warningWidget(
            '"${'.'.allMatches(_projectOrg ?? '').length == 1 ? '$_projectOrg.${widget.projName}' : _projectOrg}" will be your organization name. You can change it later.',
            Assets.done,
            kGreenColor,
          ),
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
        if (_projectOrg != null && '.'.allMatches(_projectOrg!).length > 2)
          warningWidget(
            'Please check your organization name. This doesn\'t seem to be a proper one. Try something like com.${widget.projName}.app',
            Assets.error,
            kRedColor,
          ),
        infoWidget(
            'The organization responsible for your new Flutter project, in reverse domain name notation. This string is used in Java package names and as prefix in the iOS bundle identifier.'),
      ],
    );
  }
}
