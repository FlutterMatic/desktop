// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:file_selector/file_selector.dart' as file_selector;
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/inputs/text_field.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/core/services/logs.dart';

class FlutterProjectPreConfigSection extends StatefulWidget {
  final String orgName;
  final Map<String, dynamic> firebaseJson;
  final List<String> firebasePlist;
  final List<String> firebaseWebConfig;
  final Function(Map<String, dynamic> json) onJsonUpload;
  final Function(List<String> plist) onPlistUpload;
  final Function(List<String> webConfig) onWebConfigUpload;

  // Platform to show the buttons only for them.
  final bool isIos;
  final bool isAndroid;
  final bool isWeb;

  const FlutterProjectPreConfigSection({
    Key? key,
    required this.orgName,
    required this.onJsonUpload,
    required this.firebaseJson,
    required this.firebasePlist,
    required this.firebaseWebConfig,
    required this.onPlistUpload,
    required this.onWebConfigUpload,
    required this.isIos,
    required this.isAndroid,
    required this.isWeb,
  }) : super(key: key);

  @override
  _FlutterProjectPreConfigSectionState createState() =>
      _FlutterProjectPreConfigSectionState();
}

class _FlutterProjectPreConfigSectionState
    extends State<FlutterProjectPreConfigSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        infoWidget(
          context,
          'You can easily setup common environments for Flutter such as Firebase. More coming soon.',
        ),
        VSeparators.small(),
        RoundContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'Have a Firebase backend you want to connect to?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  HSeparators.normal(),
                  SvgPicture.asset(Assets.firebase, height: 18),
                ],
              ),
              VSeparators.small(),
              const Text(
                'Upload your "google-services.json" file, "GoogleService-Info.plist" file, or web config code if you want to automatically setup Firebase.',
              ),
              VSeparators.normal(),
              if (!widget.isIos && !widget.isAndroid && !widget.isWeb)
                informationWidget(
                    'Adding Firebase pre-config is currently only supported for iOS, Android and Web. Change your platforms to add Firebase support.')
              else
                Row(
                  children: <Widget>[
                    if (widget.isAndroid)
                      Expanded(
                        child: RectangleButton(
                          child: const Text('Upload .json'),
                          onPressed: () async {
                            file_selector.XFile? _file =
                                await file_selector.openFile(
                              confirmButtonText: 'Upload',
                            );

                            if (_file == null) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                snackBarTile(
                                  context,
                                  'Please select your "google-services.json" file to setup Firebase.',
                                  type: SnackBarType.error,
                                ),
                              );
                              return;
                            }

                            // Make sure it's a valid file
                            if (!_file.path.endsWith('.json')) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                snackBarTile(
                                  context,
                                  'The file you selected is an invalid "google-services.json" file.',
                                  type: SnackBarType.error,
                                ),
                              );
                              return;
                            }

                            // Make sure that the file name is "google-services.json"
                            if (_file.name != 'google-services.json') {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                snackBarTile(
                                  context,
                                  'Make sure that the file you selected is "google-services.json" file.',
                                  type: SnackBarType.error,
                                ),
                              );
                              return;
                            }

                            try {
                              // Read and extract the file.
                              Map<String, dynamic> _googleServices =
                                  jsonDecode(await _file.readAsString());

                              String _orgName = _googleServices['client'][0]
                                      ['client_info']['android_client_info']
                                  ['package_name'];

                              if (_orgName != widget.orgName) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  snackBarTile(
                                    context,
                                    'The file you selected is not for the current organization. Make sure organization name matches.',
                                    type: SnackBarType.error,
                                  ),
                                );
                                return;
                              }

                              widget.onJsonUpload(_googleServices);

                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                snackBarTile(
                                  context,
                                  'Successfully uploaded your "google-services.json" file. Your Flutter project will be setup to use Firebase.',
                                  type: SnackBarType.done,
                                ),
                              );
                            } catch (_) {
                              await logger.file(LogTypeTag.error,
                                  'Couldn\'t upload "google-services.json" file. $_');
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                snackBarTile(
                                  context,
                                  'Failed to upload your "google-services.json" file. Please make sure that the file is valid and not modified.',
                                  type: SnackBarType.error,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    if (widget.isIos) ...<Widget>[
                      if (widget.isAndroid) HSeparators.normal(),
                      Expanded(
                        child: RectangleButton(
                          child: const Text('Upload .plist'),
                          onPressed: () async {
                            file_selector.XFile? _file =
                                await file_selector.openFile(
                              confirmButtonText: 'Upload',
                            );

                            if (_file == null) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                snackBarTile(
                                  context,
                                  'Please select your "GoogleService-Info.plist" file to setup Firebase.',
                                  type: SnackBarType.error,
                                ),
                              );
                              return;
                            }

                            // Make sure it's a valid file
                            if (!_file.path.endsWith('.plist')) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                snackBarTile(
                                  context,
                                  'The file you selected is an invalid "GoogleService-Info.plist" file.',
                                  type: SnackBarType.error,
                                ),
                              );
                              return;
                            }

                            // Make sure that the file name is "google-services.json"
                            if (_file.name != 'GoogleService-Info.plist') {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                snackBarTile(
                                  context,
                                  'Make sure that the file you selected is "GoogleService-Info.plist" file.',
                                  type: SnackBarType.error,
                                ),
                              );
                              return;
                            }

                            try {
                              // Read and extract the file.
                              List<String> _plist =
                                  await File(_file.path).readAsLines();

                              widget.onPlistUpload(_plist);

                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                snackBarTile(
                                  context,
                                  'Successfully uploaded your "GoogleService-Info.plist" file. Your Flutter project will be setup to use Firebase.',
                                  type: SnackBarType.done,
                                ),
                              );
                            } catch (_) {
                              await logger.file(LogTypeTag.error,
                                  'Couldn\'t upload "GoogleService-Info.plist" file. $_');
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                snackBarTile(
                                  context,
                                  'Failed to upload your "GoogleService-Info.plist" file. Please make sure that the file is valid and not modified.',
                                  type: SnackBarType.error,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                    if (widget.isWeb) ...<Widget>[
                      if (widget.isIos || widget.isAndroid)
                        HSeparators.normal(),
                      Expanded(
                        child: RectangleButton(
                          child: const Text('Add Web Config'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => _AddWebConfig(
                                onWebConfigUpload: (List<String> webConfig) {
                                  widget.onWebConfigUpload(webConfig);
                                  ScaffoldMessenger.of(context)
                                      .clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    snackBarTile(
                                      context,
                                      'Successfully uploaded your web config. Your Flutter web project will be setup to use Firebase.',
                                      type: SnackBarType.done,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ]
                  ],
                ),
            ],
          ),
        ),
        if (widget.firebaseWebConfig.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: RoundContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(Icons.web_rounded, size: 18),
                      HSeparators.small(),
                      const Expanded(child: Text('Web Config Added')),
                      Tooltip(
                        message: 'Remove',
                        waitDuration: const Duration(seconds: 1),
                        child: SquareButton(
                          icon: const Icon(Icons.close_rounded, size: 15),
                          onPressed: () {
                            List<String> _config = widget.firebaseWebConfig;

                            widget.onWebConfigUpload(<String>[]);

                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              snackBarTile(
                                context,
                                'Your Firebase web project has been removed.',
                                type: SnackBarType.done,
                                action: snackBarAction(
                                  text: 'Undo',
                                  onPressed: () =>
                                      widget.onWebConfigUpload(_config),
                                ),
                              ),
                            );
                          },
                          color: Colors.transparent,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        if (widget.firebaseJson.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: RoundContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(Icons.android_rounded, size: 18),
                      HSeparators.small(),
                      Expanded(
                        child: Text(
                          widget.firebaseJson['project_info']['project_id'] +
                              ' - Android',
                        ),
                      ),
                      Tooltip(
                        message: 'Remove',
                        waitDuration: const Duration(seconds: 1),
                        child: SquareButton(
                          icon: const Icon(Icons.close_rounded, size: 15),
                          onPressed: () {
                            Map<String, dynamic> _json = widget.firebaseJson;

                            widget.onJsonUpload(<String, dynamic>{});

                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              snackBarTile(
                                context,
                                'Your Firebase Android project has been removed.',
                                type: SnackBarType.done,
                                action: snackBarAction(
                                  text: 'Undo',
                                  onPressed: () => widget.onJsonUpload(_json),
                                ),
                              ),
                            );
                          },
                          color: Colors.transparent,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  VSeparators.normal(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Project number: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(
                          widget.firebaseJson['project_info']['project_number'],
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        if (widget.firebasePlist.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: RoundContainer(
              child: Builder(
                builder: (_) {
                  String _projectId = 'Unknown';
                  String _gcmSenderId = 'Unknown';

                  for (int i = 0; i < widget.firebasePlist.length; i++) {
                    if (widget.firebasePlist[i].trim() ==
                        '<key>GCM_SENDER_ID</key>') {
                      _gcmSenderId = widget.firebasePlist[i + 1]
                          .trim()
                          .split('<string>')[1]
                          .split('</string>')
                          .first;
                    }
                  }

                  for (int i = 0; i < widget.firebasePlist.length; i++) {
                    if (widget.firebasePlist[i].trim() ==
                        '<key>PROJECT_ID</key>') {
                      _projectId = widget.firebasePlist[i + 1]
                          .trim()
                          .split('<string>')[1]
                          .split('</string>')
                          .first;
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(Icons.phone_iphone_rounded, size: 18),
                          HSeparators.small(),
                          Expanded(
                            child: Text(_projectId + ' - iOS'),
                          ),
                          Tooltip(
                            message: 'Remove',
                            waitDuration: const Duration(seconds: 1),
                            child: SquareButton(
                              icon: const Icon(Icons.close_rounded, size: 15),
                              onPressed: () {
                                List<String> _plist = widget.firebasePlist;

                                widget.onPlistUpload(<String>[]);

                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  snackBarTile(
                                    context,
                                    'Your Firebase iOS project has been removed.',
                                    type: SnackBarType.done,
                                    action: snackBarAction(
                                      text: 'Undo',
                                      onPressed: () =>
                                          widget.onPlistUpload(_plist),
                                    ),
                                  ),
                                );
                              },
                              color: Colors.transparent,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                      VSeparators.normal(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Project number: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: Text(
                              _gcmSenderId,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      // If both org names are not the same, we want to warn the
                      // user that the project is not connecting to the correct
                      // Firebase project. Each platform connects to a different
                      // Firebase project. We want to confirm that this is the
                      // expected behavior for the user.
                      if (widget.firebaseJson.isNotEmpty &&
                          (widget.firebaseJson['project_info']
                                  ['project_number'] !=
                              _gcmSenderId))
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: informationWidget(
                              'The project number in the Firebase Android project does not match the project number in the Firebase iOS project. This may cause issues connecting to the Firebase project and each platform will connect to a different Firebase project.'),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _AddWebConfig extends StatefulWidget {
  final Function(List<String> webConfig) onWebConfigUpload;

  const _AddWebConfig({
    Key? key,
    required this.onWebConfigUpload,
  }) : super(key: key);

  @override
  __AddWebConfigState createState() => __AddWebConfigState();
}

class __AddWebConfigState extends State<_AddWebConfig> {
  final TextEditingController _webConfigController = TextEditingController();

  static const List<String> _sample = <String>[
    'Paste your web config code. Example:',
    '// Import the functions you need from the SDKs you need',
    'import { initializeApp } from "firebase/app";',
    '',
    '// Your web app\'s Firebase configuration',
    'const firebaseConfig = {',
    '  apiKey: "[...]",',
    '  authDomain: "[...].firebaseapp.com",',
    '  projectId: "[...]",',
    '  storageBucket: "[...].appspot.com",',
    '  messagingSenderId: "[...]",',
    '  appId: "1:[...]:web:[...]",',
    '  measurementId: "G-[...]"',
    '};',
    '',
    '// Initialize Firebase',
    'const app = initializeApp(firebaseConfig);',
  ];

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          const DialogHeader(title: 'Add Web Config'),
          CustomTextField(
            numLines: 18,
            controller: _webConfigController,
            hintText: _sample.join('\n'),
          ),
          VSeparators.normal(),
          Row(
            children: <Widget>[
              Expanded(
                child: RectangleButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              HSeparators.normal(),
              Expanded(
                child: RectangleButton(
                  child: const Text('Add'),
                  onPressed: () {
                    // Will validate the inputted web config.
                    if (_webConfigController.text.isEmpty) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
                        context,
                        'Please add the web config code to continue',
                        type: SnackBarType.error,
                      ));
                      return;
                    }

                    List<String> _mustContain = <String>[
                      'import { initializeApp } from "firebase/app";',
                      'const firebaseConfig = {',
                      'apiKey: ',
                      'authDomain: ',
                      'projectId: ',
                      'storageBucket: ',
                      'messagingSenderId: ',
                      'appId: ',
                      'measurementId: ',
                      'initializeApp(firebaseConfig)',
                    ];

                    for (String _mustContainItem in _mustContain) {
                      if (_webConfigController.text
                          .contains(_mustContainItem)) {
                        continue;
                      }

                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
                        context,
                        'Please make sure to copy the entire web config code. This is invalid.',
                        type: SnackBarType.error,
                      ));
                      return;
                    }

                    widget.onWebConfigUpload(
                        _webConfigController.text.split('\n'));
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
