import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/components/widgets/buttons/rectangle_button.dart';
import 'package:manager/components/widgets/inputs/text_field.dart';
import 'package:manager/components/widgets/ui/dialog_template.dart';
import 'package:manager/components/widgets/ui/info_widget.dart';
import 'package:manager/components/widgets/ui/snackbar_tile.dart';
import 'package:process_run/shell_run.dart';
import 'dart:io';

class OpenOptionsDialog extends StatelessWidget {
  OpenOptionsDialog(this.fileName);
  final String fileName;
  final Shell _shell = Shell(
    verbose: false,
  );
  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const DialogHeader(title: 'Project Options'),
          const SizedBox(height: 20),
          // Row 1
          Row(
            children: <Widget>[
              // Open in Default Editor
              _projectOptionTile(
                context: context,
                title: 'Open w/ Default Editor',
                icon: Icons.source_rounded,
                hoverType: HoverType.normal,
                onPressed: () async {
                  // TODO: Open the project in the default editor.
                },
              ),
              const SizedBox(width: 10),
              // Open With
              _projectOptionTile(
                context: context,
                title: 'Open With...',
                icon: Icons.open_with_rounded,
                hoverType: HoverType.normal,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => OpenWithOptionsDialog(name: fileName),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Row 2
          Row(
            children: <Widget>[
              // Open in File Explorer / Finder
              _projectOptionTile(
                context: context,
                title:
                    'View in ${Platform.isMacOS ? 'Finder' : 'File Explorer'}',
                icon: Icons.file_present_rounded,
                hoverType: HoverType.normal,
                onPressed: () {
                  try {
                    // TODO: Open in the user Finder/File Explorer
                  } catch (_) {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (_) => DialogTemplate(
                        child: Column(
                          children: <Widget>[
                            const DialogHeader(title: 'Couldn\'t Open'),
                            const SizedBox(height: 20),
                            Text(
                              'Sorry, for some reason, we couldn\'t open $fileName. Please make sure that this project exists. If this issue continues to happen, then please raise an issue on GitHub.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            RectangleButton(
                              onPressed: () => Navigator.pop(context),
                              width: double.infinity,
                              color: Colors.blueGrey,
                              splashColor: Colors.blueGrey.withOpacity(0.5),
                              focusColor: Colors.blueGrey.withOpacity(0.5),
                              hoverColor: Colors.grey.withOpacity(0.5),
                              highlightColor: Colors.blueGrey.withOpacity(0.5),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(width: 10),
              // Delete Project
              _projectOptionTile(
                context: context,
                title: 'Delete Project',
                icon: Icons.delete_forever,
                hoverType: HoverType.warn,
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => ConfirmProjectDelete(fileName),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum HoverType { normal, warn }

Widget _projectOptionTile({
  required BuildContext context,
  required String title,
  required IconData icon,
  required HoverType hoverType,
  required Function onPressed,
}) {
  ThemeData customTheme = Theme.of(context);
  return Expanded(
    child: RectangleButton(
      onPressed: onPressed,
      color: Colors.blueGrey.withOpacity(0.2),
      hoverColor: hoverType == HoverType.normal
          ? customTheme.accentColor
          : customTheme.errorColor,
      splashColor:
          hoverType == HoverType.normal ? customTheme.accentColor : kRedColor,
      highlightColor: hoverType == HoverType.normal
          ? customTheme.accentColor
          : customTheme.errorColor,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      height: 110,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(child: Icon(icon, color: Colors.white)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: customTheme.textTheme.bodyText1!.color),
          ),
        ],
      ),
    ),
  );
}

class ConfirmProjectDelete extends StatefulWidget {
  final String fName;

  ConfirmProjectDelete(this.fName);

  @override
  _ConfirmProjectDeleteState createState() => _ConfirmProjectDeleteState();
}

class _ConfirmProjectDeleteState extends State<ConfirmProjectDelete> {
  //User Input
  String? _confirmInput;
  //Utils
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const DialogHeader(title: 'Confirm Delete'),
          const SizedBox(height: 20),
          RichText(
            text: TextSpan(
              children: <TextSpan>[
                const TextSpan(text: 'Deleting this project '),
                TextSpan(
                  text: 'cannot be undone. ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: customTheme.errorColor,
                  ),
                ),
                const TextSpan(
                  text: 'Please make sure that you are aware of this action.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Please type in below "${widget.fName}" to delete this project.',
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          CustomTextField(
            readOnly: _loading,
            onChanged: (String val) => setState(() => _confirmInput = val),
            hintText: 'Confirm Delete',
          ),
          infoWidget(
              'Your input is case-sensitive. Please make sure you type in exactly your project name.'),
          const SizedBox(height: 10),
          RectangleButton(
            width: double.infinity,
            color: customTheme.errorColor,
            hoverColor: kRedColor,
            height: 45,
            highlightColor: Colors.red,
            splashColor: kRedColor,
            disableColor: customTheme.errorColor.withOpacity(0.6),
            disable: _confirmInput != widget.fName,
            contentColor: Colors.white,
            loading: _loading,
            onPressed: () async {
              setState(() => _loading = true);
              // TODO: Delete the project when user clicks on delete.
              // Directory delProjPath = Directory('${projDir!}/${widget.fName}');
              // bool _exists = await delProjPath.exists();
              // if (_exists) {
              //   await delProjPath
              //       .delete(recursive: true)
              //       .whenComplete(() => setState(() => _loading = false));
              //   Navigator.pop(context);
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     snackBarTile(
              //       '${widget.fName} has successfully been deleted.',
              //       type: SnackBarType.done,
              //     ),
              //   );
              // } else {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
                  'Failed to delete "${widget.fName}". Project doesn\'t exist.',
                  type: SnackBarType.error));
              // }
            },
            child: const Text(
              'Delete Project',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class OpenWithOptionsDialog extends StatelessWidget {
  final String name;

  OpenWithOptionsDialog({required this.name});

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          const DialogHeader(title: 'Open Options'),
          const SizedBox(height: 20),
          // TODO: Show open options.
        ],
      ),
    );
  }
}