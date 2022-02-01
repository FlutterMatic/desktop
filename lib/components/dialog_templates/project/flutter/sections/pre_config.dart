// 🎯 Dart imports:
import 'dart:convert';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:file_selector/file_selector.dart' as file_selector;
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/core/services/logs.dart';

class FlutterProjectPreConfigSection extends StatefulWidget {
  final Map<String, dynamic>? firebaseJson;
  final Function(Map<String, dynamic>? json) onFirebaseUpload;

  const FlutterProjectPreConfigSection({
    Key? key,
    required this.onFirebaseUpload,
    required this.firebaseJson,
  }) : super(key: key);

  @override
  _FlutterProjectPreConfigSectionState createState() =>
      _FlutterProjectPreConfigSectionState();
}

class _FlutterProjectPreConfigSectionState extends State<FlutterProjectPreConfigSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        infoWidget(
          context,
          'You can easily setup common environments for Flutter such as Firebase. More coming soon.',
        ),
        VSeparators.normal(),
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: RoundContainer(
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

                      widget.onFirebaseUpload(_googleServices);

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
              ],
            ),
          ),
        ),
        if (widget.firebaseJson != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: RoundContainer(
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SvgPicture.asset(Assets.firebase, height: 20),
                      HSeparators.small(),
                      Expanded(
                        child: Text(
                          widget.firebaseJson!['project_info']!['project_id'],
                        ),
                      ),
                      Tooltip(
                        message: 'Remove',
                        waitDuration: const Duration(seconds: 1),
                        child: SquareButton(
                          icon: const Icon(Icons.close_rounded, size: 15),
                          onPressed: () {
                            Map<String, dynamic>? _firebaseJson =
                                widget.firebaseJson;

                            widget.onFirebaseUpload(null);

                            ScaffoldMessenger.of(context).clearSnackBars();
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
