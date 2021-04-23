import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/dialog_header.dart';
import 'package:flutter_installer/components/widgets/close_button.dart';
import 'package:flutter_installer/components/widgets/dialog_template.dart';
import 'package:flutter_installer/components/widgets/info_widget.dart';
import 'package:flutter_installer/components/widgets/rectangle_button.dart';
import 'package:flutter_installer/components/widgets/text_field.dart';
import 'package:flutter_installer/services/flutter_actions.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:process_run/shell_run.dart';
import 'dart:developer' as console;
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class OpenOptionsDialog extends StatelessWidget {
  OpenOptionsDialog(this.fileName);
  final String fileName;
  final Shell _shell = Shell(
    verbose: false,
  );
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
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                color: customTheme.primaryColor,
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (_) => ConfirmProjectDelete(fileName),
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
                          Icon(Iconsdata.delete, color: customTheme.errorColor),
                        ],
                      ),
                    ),
                  ),
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
                alignment: Alignment.centerRight,
                child: CustomCloseButton(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: RectangleButton(
                  onPressed: () async {
                    if (defaultEditor == 'code') {
                      await _shell.run('$defaultEditor $projDir\\$fileName');
                    } else {
                      await _shell.run('$defaultEditor $projDir\\$fileName');
                    }
                  },
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
                        child: Icon(Icons.folder_open, color: Colors.blueGrey),
                      ),
                      Text(
                        'Open',
                        style: TextStyle(
                          color: customTheme.textTheme.bodyText1!.color,
                        ),
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
                        child: Icon(Icons.code_rounded, color: Colors.blueGrey),
                      ),
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
                  onPressed: () {
                    try {
                      launch('${projDir!}\\$fileName');
                    } catch (_) {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (_) => DialogTemplate(
                          child: Column(
                            children: [
                              DialogHeader(title: 'Couldn\'t Open'),
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
                                highlightColor:
                                    Colors.blueGrey.withOpacity(0.5),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
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
                        child: Icon(Icons.file_present, color: Colors.blueGrey),
                      ),
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
  ConfirmProjectDelete(this.fName);
  final String fName;
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
          Text(
            'Please type in below "${widget.fName}" to delete this project.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            readOnly: _loading,
            onChanged: (val) => setState(() => _confirmInput = val),
            hintText: 'Confirm Delete',
          ),
          infoWidget(
              'Your input is case-sensitive. Please make sure you type in exactly your project name.'),
          const SizedBox(height: 10),
          RectangleButton(
            width: double.infinity,
            color: customTheme.errorColor,
            hoverColor: kRedColor,
            highlightColor: Colors.red,
            splashColor: kRedColor,
            disableColor: Colors.red.withOpacity(0.5),
            disable: _confirmInput != widget.fName,
            contentColor: Colors.white,
            loading: _loading,
            onPressed: () async {
              setState(() => _loading = true);
              Directory delProjPath = Directory('${projDir!}/${widget.fName}');
              if (await delProjPath.exists()) {
                await delProjPath
                    .delete(recursive: true)
                    .whenComplete(() async {
                  await flutterActions.checkProjects();
                  setState(() => _loading = false);
                  await showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (_) => DialogTemplate(
                      outerTapExit: false,
                      child: Column(
                        children: [
                          DialogHeader(title: 'File Deleted', canClose: false),
                          const SizedBox(height: 20),
                          const Text('Your project has been deleted.'),
                          const SizedBox(height: 15),
                          RectangleButton(
                            width: double.infinity,
                            color: Colors.blueGrey,
                            splashColor: Colors.blueGrey.withOpacity(0.5),
                            focusColor: Colors.blueGrey.withOpacity(0.5),
                            hoverColor: Colors.grey.withOpacity(0.5),
                            highlightColor: Colors.blueGrey.withOpacity(0.5),
                            onPressed: () {
                              try {
                                Navigator.of(context).pop(true);
                                Navigator.pop(context);
                              } catch (e) {
                                console.log(e.toString());
                              }
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    ),
                  );
                });
              } else {
                await showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (_) => DialogTemplate(
                    outerTapExit: false,
                    child: Column(
                      children: [
                        DialogHeader(
                            title: 'Failed to delete', canClose: false),
                        const SizedBox(height: 20),
                        Text(
                            'Failed to delete your project ${widget.fName}. Check if you have the project in your directory.'),
                        const SizedBox(height: 15),
                        RectangleButton(
                          width: double.infinity,
                          color: Colors.blueGrey,
                          splashColor: Colors.blueGrey.withOpacity(0.5),
                          focusColor: Colors.blueGrey.withOpacity(0.5),
                          hoverColor: Colors.grey.withOpacity(0.5),
                          highlightColor: Colors.blueGrey.withOpacity(0.5),
                          onPressed: () {
                            try {
                              Navigator.of(context).pop(true);
                              Navigator.pop(context);
                            } catch (e) {
                              console.log(e.toString());
                            }
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                );
              }
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

class ProjectDeletedDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: [
          DialogHeader(title: 'Project Deleted'),
          const SizedBox(height: 20),
          SvgPicture.asset(Assets.done),
          const SizedBox(height: 20),
          const Text(
            'Your project has successfully been deleted.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
