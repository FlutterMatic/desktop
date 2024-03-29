// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/widgets/inputs/text_field.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';

class FlutterProjectDescriptionSection extends StatefulWidget {
  final TextEditingController controller;

  const FlutterProjectDescriptionSection({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  _FlutterProjectDescriptionSectionState createState() =>
      _FlutterProjectDescriptionSectionState();
}

class _FlutterProjectDescriptionSectionState
    extends State<FlutterProjectDescriptionSection> {
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
          validator: (String? pDesc) =>
              pDesc!.isEmpty ? 'Please enter project description' : null,
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
