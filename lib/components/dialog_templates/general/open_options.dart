import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/dialog_header.dart';
import 'package:flutter_installer/components/widgets/close_button.dart';
import 'package:flutter_installer/components/widgets/dialog_template.dart';
import 'package:flutter_installer/components/widgets/rectangle_button.dart';
import 'package:flutter_installer/components/widgets/text_field.dart';
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
              PopupMenuButton(
                color: customTheme.primaryColor,
                itemBuilder: (BuildContext _) => [
                  PopupMenuItem(
                      child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (_) => ConfirmProjectDelete(),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          'Delete',
                          style: TextStyle(
                              color: customTheme.textTheme.bodyText1!.color),
                        ),
                        const Spacer(),
                        Icon(Icons.delete, color: customTheme.errorColor),
                      ],
                    ),
                  )),
                ],
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Project Options',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              Align(
                  alignment: Alignment.centerRight, child: CustomCloseButton()),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: RectangleButton(
                  onPressed: () {},
                  color: Colors.blueGrey.withOpacity(0.2),
                  hoverColor: Colors.blueGrey.withOpacity(0.3),
                  highlightColor: Colors.blueGrey.withOpacity(0.8),
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  height: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(
                          child:
                              Icon(Icons.folder_open, color: Colors.blueGrey)),
                      Text(
                        'Open',
                        style: TextStyle(
                            color: customTheme.textTheme.bodyText1!.color),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RectangleButton(
                  onPressed: () {},
                  color: Colors.blueGrey.withOpacity(0.2),
                  hoverColor: Colors.blueGrey.withOpacity(0.3),
                  highlightColor: Colors.blueGrey.withOpacity(0.8),
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  height: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(
                          child:
                              Icon(Icons.code_rounded, color: Colors.blueGrey)),
                      Text(
                        'Open with...',
                        style: TextStyle(
                            color: customTheme.textTheme.bodyText1!.color),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RectangleButton(
                  onPressed: () {},
                  color: Colors.blueGrey.withOpacity(0.2),
                  hoverColor: Colors.blueGrey.withOpacity(0.3),
                  highlightColor: Colors.blueGrey.withOpacity(0.8),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  height: 100,
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(
                          child:
                              Icon(Icons.file_present, color: Colors.blueGrey)),
                      Text(
                        'View in ${Platform.isMacOS ? 'Finder' : 'File Explorer'}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: customTheme.textTheme.bodyText1!.color),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
          DialogHeader(title: 'Confirm Delete'),
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
          const SizedBox(height: 10),
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
