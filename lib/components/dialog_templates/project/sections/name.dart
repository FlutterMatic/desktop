// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:file_selector/file_selector.dart' as file_selector;

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/app/constants/shared_pref.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/inputs/text_field.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/components/widgets/ui/warning_widget.dart';
import 'package:fluttermatic/meta/utils/shared_pref.dart';

class ProjectNameSection extends StatefulWidget {
  final String? path;
  final Function(String path) onPathUpdate;
  final TextEditingController controller;

  const ProjectNameSection({
    Key? key,
    required this.controller,
    required this.path,
    required this.onPathUpdate,
  }) : super(key: key);

  @override
  _ProjectNameSectionState createState() => _ProjectNameSectionState();
}

class _ProjectNameSectionState extends State<ProjectNameSection> {
  bool _showedUpperCaseWarning = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CustomTextField(
          autofocus: true,
          controller: widget.controller,
          hintText: 'Project Name',
          filterFormatters: <TextInputFormatter>[
            TextInputFormatter.withFunction(
                (TextEditingValue oldValue, TextEditingValue newValue) {
              if (newValue.text.length > 70) {
                return oldValue;
              } else {
                if (newValue.text.toLowerCase() != newValue.text &&
                    !_showedUpperCaseWarning) {
                  // Shows a snackbar informing them that the project name must
                  // be lowercase but still allows them to continue by auto
                  // correcting the text.
                  ScaffoldMessenger.of(context).showSnackBar(
                    snackBarTile(
                      context,
                      'Note that you cannot have any uppercase letters in your project name. We have lower-cased it for you.',
                    ),
                  );

                  setState(() => _showedUpperCaseWarning = true);
                }
                return newValue.copyWith(
                    text: newValue.text.replaceAll(' ', '_').toLowerCase());
              }
            }),
            FilteringTextInputFormatter.allow(RegExp('[a-zA-Z-_0-9 ]')),
          ],
          onChanged: (_) => setState(() {}),
          validator: (String? val) => val!.isEmpty
              ? 'Enter project name'
              : val.length < 3
                  ? 'Too short, try adding some more'
                  : null,
          maxLength: 70,
        ),
        VSeparators.small(),
        // Checks if name doesn't start with a lower-case letter
        if (widget.controller.text != '' &&
            !widget.controller.text.startsWith(RegExp('[a-zA-Z]')))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: informationWidget(
              'Your project name needs to start with a lower-case English character (a-z).',
              type: InformationType.error,
            ),
          ),
        // Checks if there are numbers included in the project name
        if (widget.controller.text != '' &&
            widget.controller.text.contains(RegExp('[0-9]')))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: informationWidget(
              'You can\'t have any numbers in your project name. Try using characters such as English letters (a-z) and underscores (_).',
              type: InformationType.error,
            ),
          ),
        // Checks to see if there are any upper-case letters
        if (widget.controller.text != '' &&
            widget.controller.text.contains(RegExp(r'[A-Z]')))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: informationWidget(
              'Any upper-case letters in the project name will be turned to a lower-case letter.',
              type: InformationType.warning,
            ),
          ),
        // Checks to see if lower-case letter is started with
        if (widget.controller.text != '' &&
            widget.controller.text.startsWith(RegExp('[a-zA-Z]')) &&
            !widget.controller.text.contains(RegExp('[0-9]')))
          if (widget.controller.text.length < 3)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: informationWidget(
                'Your project name has to be at least 3 characters long.',
                type: InformationType.info,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: informationWidget(
                'Your new project will be called "${widget.controller.text.trim().replaceAll(RegExp(r'-| '), '_').toLowerCase()}"',
                type: InformationType.green,
              ),
            ),
        infoWidget(context,
            'Your project name can only include lower-case English letters (a-z) and underscores (_).'),
        VSeparators.normal(),
        RoundContainer(
          color: Colors.blueGrey.withOpacity(0.2),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                        'Select the path where you want to save your project.'),
                    VSeparators.xSmall(),
                    Tooltip(
                      waitDuration: const Duration(milliseconds: 500),
                      message: widget.path ??
                          SharedPref().pref.getString(SPConst.projectsPath) ??
                          '',
                      child: Text(
                        widget.path ??
                            SharedPref().pref.getString(SPConst.projectsPath) ??
                            'No path selected',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              HSeparators.normal(),
              RectangleButton(
                width: 100,
                child:
                    Text(widget.path == null ? 'Select Path' : 'Change path'),
                onPressed: () async {
                  String? _path = await file_selector.getDirectoryPath();

                  if (_path == null) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      snackBarTile(
                        context,
                        'Please select a path.',
                        type: widget.path == null
                            ? SnackBarType.error
                            : SnackBarType.warning,
                      ),
                    );
                    return;
                  }

                  widget.onPathUpdate(_path);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
