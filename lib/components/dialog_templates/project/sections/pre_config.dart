// 🎯 Dart imports:
import 'dart:convert';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:file_selector/file_selector.dart' as file_selector;
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/core/libraries/widgets.dart';

class ProjectPreConfigSection extends StatefulWidget {
  final Map<String, dynamic>? firebaseJson;
  final Function(Map<String, dynamic>? json) onFirebaseUpload;

  const ProjectPreConfigSection({
    Key? key,
    required this.onFirebaseUpload,
    required this.firebaseJson,
  }) : super(key: key);

  @override
  _ProjectPreConfigSectionState createState() =>
      _ProjectPreConfigSectionState();
}

class _ProjectPreConfigSectionState extends State<ProjectPreConfigSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        infoWidget(
          context,
          'You can easily setup common environments for Flutter such as Firebase.',
        ),
        VSeparators.normal(),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: RoundContainer(
            color: Colors.blueGrey.withOpacity(0.2),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      const Text(
                        'Have a Firebase backend you want to connect to?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      VSeparators.small(),
                      const Text(
                        'Upload your "google-services.json" file if you want to automatically setup Firebase.',
                      ),
                    ],
                  ),
                ),
                HSeparators.normal(),
                RectangleButton(
                  child: const Text('Upload'),
                  width: 100,
                  onPressed: () async {
                    file_selector.XFile? _file = await file_selector.openFile(
                      confirmButtonText: 'Upload',
                    );

                    if (_file == null) {
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

                      widget.onFirebaseUpload(_googleServices);

                      ScaffoldMessenger.of(context).showSnackBar(
                        snackBarTile(
                          context,
                          'Successfully uploaded your "google-services.json" file. Your Flutter project will be setup to use Firebase.',
                          type: SnackBarType.done,
                        ),
                      );
                    } catch (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        snackBarTile(
                          context,
                          'Failed to upload your "google-services.json" file. Please make sure that the file is valid and not modified.',
                          type: SnackBarType.error,
                        ),
                      );
                      await logger.file(LogTypeTag.error,
                          'Couldn\'t upload "google-services.json" file. $_');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        if (widget.firebaseJson != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: RoundContainer(
              color: Colors.blueGrey.withOpacity(0.1),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SvgPicture.asset(Assets.firebase, height: 20),
                      const Spacer(),
                      SquareButton(
                        icon: const Icon(Icons.close_rounded, size: 15),
                        onPressed: () {
                          Map<String, dynamic>? _firebaseJson =
                              widget.firebaseJson;
                          widget.onFirebaseUpload(null);
                          ScaffoldMessenger.of(context).showSnackBar(
                            snackBarTile(
                              context,
                              'Your Firebase project has been removed.',
                              type: SnackBarType.done,
                              action: snackBarAction(
                                text: 'Undo',
                                onPressed: () =>
                                    widget.onFirebaseUpload(_firebaseJson),
                              ),
                            ),
                          );
                        },
                        color: Colors.transparent,
                        size: 22,
                      ),
                    ],
                  ),
                  VSeparators.normal(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Project Name: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(
                          widget.firebaseJson!['project_info']!['project_id'],
                        ),
                      ),
                    ],
                  ),
                  VSeparators.small(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Project number: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(
                          widget
                              .firebaseJson!['project_info']!['project_number'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        VSeparators.normal(),
      ],
    );
  }
}
