// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/inputs/text_field.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';

class FlutterProjectOrgNameSection extends StatefulWidget {
  final String projName;
  final TextEditingController controller;

  const FlutterProjectOrgNameSection({
    Key? key,
    required this.projName,
    required this.controller,
  }) : super(key: key);

  @override
  _FlutterProjectOrgNameSectionState createState() => _FlutterProjectOrgNameSectionState();
}

class _FlutterProjectOrgNameSectionState extends State<FlutterProjectOrgNameSection> {
  @override
  Widget build(BuildContext context) {
    String _proposedName = '.'.allMatches(widget.controller.text).length == 1
        ? '${widget.controller.text}.${widget.projName}'
        : widget.controller.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CustomTextField(
          autofocus: true,
          controller: widget.controller,
          filterFormatters: <TextInputFormatter>[
            TextInputFormatter.withFunction(
                (TextEditingValue oldValue, TextEditingValue newValue) {
              if (newValue.text.length > 30) {
                return oldValue;
              } else {
                return newValue.copyWith(
                  text: formatOrgName(
                    pkgName: widget.projName,
                    beforeName: oldValue.text,
                    orgName: newValue.text,
                  ),
                );
              }
            }),
            // Allow spaces
            FilteringTextInputFormatter.allow(RegExp('[a-zA-Z \\_.]')),
          ],
          hintText: 'Project Organization (com.example.${widget.projName})',
          validator: (String? val) => val!.isEmpty
              ? 'Please enter project organization'
              : val.length > 30
                  ? 'Organization name is too long. Try (com.example.${widget.projName})'
                  : null,
          maxLength: 30,
          onChanged: (_) => setState(() {}),
        ),
        VSeparators.normal(),
        if (widget.controller.text != '' &&
            widget.controller.text.contains('.') &&
            widget.controller.text.contains(RegExp('[A-Za-z_]')) &&
            !widget.controller.text.endsWith('.') &&
            !widget.controller.text.endsWith('_') &&
            '.'.allMatches(widget.controller.text).length < 3)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: informationWidget(
              '"${_proposedName.startsWith('.') ? 'example' + _proposedName : _proposedName}" will be your organization name. You can change it later.',
              type: InformationType.green,
            ),
          ),
        if (widget.controller.text != '' &&
            (widget.controller.text.endsWith('_') ||
                widget.controller.text.endsWith('.') ||
                !widget.controller.text.contains('.')) &&
            '.'.allMatches(widget.controller.text).length < 3)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: informationWidget(
              'Invalid organization name. Make sure it doesn\'t end with "." or "_" and that it matches something like "com.example.app"',
              type: InformationType.warning,
            ),
          ),
        if (widget.controller.text != '' &&
            '.'.allMatches(widget.controller.text).length > 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: informationWidget(
              'Please check your organization name. This doesn\'t seem to be a proper one. Try something like com.${widget.projName}.app',
              type: InformationType.error,
            ),
          ),
        infoWidget(context,
            'The organization responsible for your new Flutter project, in reverse domain name notation. This string is used in Java package names and as prefix in the iOS bundle identifier.'),
      ],
    );
  }
}

String formatOrgName({
  required String pkgName,
  required String beforeName,
  required String orgName,
}) {
  String _result = '';

  // There can't be more than 2 dots. If there is, it will trim what is after the third dot.
  if ('.'.allMatches(orgName).length > 2) {
    _result =
        orgName.substring(0, orgName.indexOf('.', orgName.indexOf('.') + 1));
  } else {
    // The [orgName] cannot start with "." or "_". Also, there cannot be "." or "_"
    // after each other.
    if (orgName.startsWith('.') || orgName.startsWith('_')) {
      _result = beforeName;
    } else {
      // Will iterate over the [orgName] and check if there is a "." or "_" after
      // each other. We know for sure that it won't start with "." or "_" because
      // of the previous if statement.
      // There also can't be a "." after or before it a "_" and vice versa.
      for (int i = 0; i < orgName.length; i++) {
        if (orgName[i] == '.' || orgName[i] == '_') {
          if (i + 1 < orgName.length &&
              (orgName[i + 1] == '.' || orgName[i + 1] == '_')) {
            _result = beforeName;
            break;
          }
        }
      }

      // If there is no "." or "_" after each other, then it will just return the
      // [orgName].
      if (_result.isEmpty) {
        _result = orgName;
      }
    }
  }

  return _result.replaceAll(' ', '_');
}
