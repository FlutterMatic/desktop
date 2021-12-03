import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/inputs/check_box_element.dart';
import 'package:manager/components/widgets/ui/warning_widget.dart';

class ProjectDartConfigSection extends StatefulWidget {
  final bool isNullSafety;

  final Function({
    bool isNullSafety,
  }) onChanged;

  const ProjectDartConfigSection({
    Key? key,
    required this.isNullSafety,
    required this.onChanged,
  }) : super(key: key);

  @override
  _ProjectDartConfigSectionState createState() =>
      _ProjectDartConfigSectionState();
}

class _ProjectDartConfigSectionState extends State<ProjectDartConfigSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        informationWidget(
          'Dart supports null-safety. Null safety helps you catch probable bugs before they happen. Learn more about null-safety from the official Dart documentations.',
          type: InformationType.info,
        ),
        VSeparators.normal(),
        CheckBoxElement(
          onChanged: (bool? val) {
            widget.onChanged(
              isNullSafety: val ?? true,
            );
          },
          value: widget.isNullSafety,
          text: 'Use null-safety',
        ),
      ],
    );
  }
}
