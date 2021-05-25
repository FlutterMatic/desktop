import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_installer/components/widgets/inputs/text_field.dart';
import 'package:flutter_installer/components/widgets/ui/info_widget.dart';

class ProjectDescriptionSection extends StatefulWidget {
  final Function(String? val) onChagned;

  ProjectDescriptionSection({required this.onChagned});

  @override
  _ProjectDescriptionSectionState createState() =>
      _ProjectDescriptionSectionState();
}

class _ProjectDescriptionSectionState extends State<ProjectDescriptionSection> {
  final TextEditingController _pDescController = TextEditingController();

  String? _projectDescription;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CustomTextField(
          autofocus: true,
          controller: _pDescController,
          filteringTextInputFormatter: FilteringTextInputFormatter.allow(
            RegExp('[a-zA-Z0-9\.\,\\s]'),
          ),
          numLines: 4,
          hintText: 'Description',
          validator: (String? _pDesc) =>
              _pDesc!.isEmpty ? 'Please enter project description' : null,
          maxLength: 150,
          onChanged: (val) {
            setState(() => _projectDescription = val.isEmpty ? null : val);
            widget.onChagned(_projectDescription);
          },
        ),
        infoWidget(
          'The description will be added as description in the pubspec.yaml file of your new project.',
        ),
      ],
    );
  }
}
