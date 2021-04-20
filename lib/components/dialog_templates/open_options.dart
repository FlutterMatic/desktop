import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_template.dart';
import 'package:flutter_installer/components/rectangle_button.dart';
import 'package:flutter_installer/components/square_button.dart';
import 'package:flutter_installer/components/text_field.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'dart:io';

class OpenOptionsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 40),
              const Expanded(
                child: Center(
                  child: Text(
                    'Project Options',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: SquareButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: customTheme.textTheme.bodyText1!.color,
                  ),
                  color: customTheme.buttonColor,
                  hoverColor: customTheme.errorColor,
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          RectangleButton(
            onPressed: () {},
            color: Colors.blueGrey.withOpacity(0.2),
            hoverColor: Colors.blueGrey.withOpacity(0.3),
            highlightColor: Colors.blueGrey.withOpacity(0.8),
            radius: const BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
            ),
            width: double.infinity,
            child: Row(
              children: [
                Text(
                  'Open',
                  style:
                      TextStyle(color: customTheme.textTheme.bodyText1!.color),
                ),
                const Spacer(),
                const Icon(Icons.folder_open, color: Colors.blueGrey),
              ],
            ),
          ),
          RectangleButton(
            onPressed: () {},
            color: Colors.blueGrey.withOpacity(0.2),
            hoverColor: Colors.blueGrey.withOpacity(0.3),
            highlightColor: Colors.blueGrey.withOpacity(0.8),
            radius: BorderRadius.zero,
            width: double.infinity,
            child: Row(
              children: [
                Text(
                  'Open with...',
                  style:
                      TextStyle(color: customTheme.textTheme.bodyText1!.color),
                ),
                const Spacer(),
                const Icon(Icons.code_rounded, color: Colors.blueGrey),
              ],
            ),
          ),
          RectangleButton(
            onPressed: () {},
            color: Colors.blueGrey.withOpacity(0.2),
            hoverColor: Colors.blueGrey.withOpacity(0.3),
            highlightColor: Colors.blueGrey.withOpacity(0.8),
            radius: const BorderRadius.only(
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(5),
            ),
            width: double.infinity,
            child: Row(
              children: [
                Text(
                  'View in ${Platform.isMacOS ? 'Finder' : 'File Explorer'}',
                  style:
                      TextStyle(color: customTheme.textTheme.bodyText1!.color),
                ),
                const Spacer(),
                const Icon(Icons.file_present, color: Colors.blueGrey),
              ],
            ),
          ),
          const SizedBox(height: 10),
          RectangleButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => ConfirmProjectDelete(),
              );
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            color: kRedColor,
            hoverColor: Colors.red,
            width: double.infinity,
            child: Row(
              children: [
                const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
                const Spacer(),
                const Icon(Icons.delete_forever_outlined, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ConfirmProjectDelete extends StatefulWidget {
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
        children: [
          Row(
            children: [
              const SizedBox(width: 40),
              const Expanded(
                child: Center(
                  child: Text(
                    'Confirm Delete',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: SquareButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: customTheme.textTheme.bodyText1!.color,
                  ),
                  color: customTheme.buttonColor,
                  hoverColor: customTheme.errorColor,
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Deleting this project cannot be undone. Please make sure that you are aware of this action.',
          ),
          const SizedBox(height: 20),
          const Text(
            'Please type in below "confirm_delete" to delete this project.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            readOnly: _loading,
            onChanged: (val) => setState(() => _confirmInput = val),
            hintText: 'Confirm Delete',
          ),
          const SizedBox(height: 20),
          RectangleButton(
            width: double.infinity,
            color: customTheme.errorColor,
            hoverColor: kRedColor,
            highlightColor: Colors.red,
            splashColor: kRedColor,
            disableColor: Colors.red.withOpacity(0.5),
            disable: _confirmInput != 'confirm_delete',
            contentColor: Colors.white,
            loading: _loading,
            onPressed: () {
              setState(() => _loading = true);
            },
            child: const Text(
              'DELETE PROJECT',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
