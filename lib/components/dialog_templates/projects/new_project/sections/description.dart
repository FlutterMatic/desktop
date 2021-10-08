// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🌎 Project imports:
import 'package:manager/core/libraries/widgets.dart';

class ProjectDescriptionSection extends StatefulWidget {
  final Function(String? val) onChanged;

  const ProjectDescriptionSection({Key? key, required this.onChanged})
      : super(key: key);

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
            RegExp('[a-zA-Z0-9.,\\s]'),
          ),
          numLines: 4,
          hintText: 'Description',
          validator: (String? _pDesc) =>
              _pDesc!.isEmpty ? 'Please enter project description' : null,
          maxLength: 150,
          onChanged: (String val) {
            setState(() => _projectDescription = val.isEmpty ? null : val);
            widget.onChanged(_projectDescription);
          },
        ),
        infoWidget(
          context,
          'The description will be added as description in the pubspec.yaml file of your new project.',
        ),
      ],
    );
  }
}
