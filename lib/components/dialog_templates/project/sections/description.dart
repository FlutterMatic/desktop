// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/core/libraries/widgets.dart';

class ProjectDescriptionSection extends StatefulWidget {
  final TextEditingController controller;

  const ProjectDescriptionSection({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  _ProjectDescriptionSectionState createState() =>
      _ProjectDescriptionSectionState();
}

class _ProjectDescriptionSectionState extends State<ProjectDescriptionSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CustomTextField(
          autofocus: true,
          controller: widget.controller,
          filteringTextInputFormatter: FilteringTextInputFormatter.allow(
            RegExp('[a-zA-Z0-9.,\\s]!?'),
          ),
          numLines: 4,
          hintText: 'Description',
          onChanged: (_) => setState(() {}),
          validator: (String? _pDesc) =>
              _pDesc!.isEmpty ? 'Please enter project description' : null,
          maxLength: 150,
        ),
        VSeparators.normal(),
        if (widget.controller.text.length > 80)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: informationWidget(
              'Tip: It\'s best to have the description be very short and concise. More details should be placed in the README.md doc file.',
              type: InformationType.warning,
            ),
          ),
        infoWidget(
          context,
          'The description will be added as description in the pubspec.yaml file of your new project.',
        ),
      ],
    );
  }
}
