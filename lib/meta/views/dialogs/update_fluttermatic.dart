// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:fluttermatic/components/widgets/ui/linear_progress_indicator.dart';

// 📦 Package imports:
import 'package:provider/src/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// 🌎 Project imports:
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/core/libraries/components.dart';
import 'package:fluttermatic/core/libraries/constants.dart';
import 'package:fluttermatic/core/libraries/notifiers.dart';
import 'package:fluttermatic/core/libraries/services.dart';

class UpdateFlutterMaticDialog extends StatefulWidget {
  final String? downloadUrl;

  const UpdateFlutterMaticDialog({
    Key? key,
    required this.downloadUrl,
  }) : super(key: key);

  @override
  _UpdateFlutterMaticDialogState createState() =>
      _UpdateFlutterMaticDialogState();
}

class _UpdateFlutterMaticDialogState extends State<UpdateFlutterMaticDialog> {
  bool _updating = false;

  String? _version;

  @override
  void initState() {
    widget.downloadUrl?.split('/').forEach((String element) {
      if (element.startsWith('v')) {
        List<String> _currentVersion = element.substring(1).split('.');
        List<String> _releaseTypes = <String>['alpha', 'beta', 'stable'];

        bool _isValid = false;

        for (int i = 0; i < _currentVersion.length; i++) {
          if (i < 2) {
            if (int.tryParse(_currentVersion[i]) != null) {
              continue;
            }
          } else {
            List<String> _finalSplit = _currentVersion[i].split('-');
            if (int.tryParse(_finalSplit[0]) == null) {
              break;
            }

            if (_releaseTypes.contains(_finalSplit[1].toLowerCase())) {
              _isValid = true;
              break;
            }
          }
        }

        if (_isValid) {
          setState(() => _version = element.toUpperCase());
          return;
        }
      }
    });

    if (_version == null) {
      _error();
    }
    super.initState();
  }

  Future<void> _error() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
      context,
      'Failed to get details about this update. Please try again later.',
      type: SnackBarType.error,
    ));
    Navigator.pop(context);
    await logger.file(
        LogTypeTag.error, 'Failed to get details about FlutterMatic update.');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: DialogTemplate(
        outerTapExit: false,
        child: IgnorePointer(
          ignoring: _version == null,
          child: Column(
            children: <Widget>[
              const DialogHeader(title: 'Update FlutterMatic', canClose: false),
              informationWidget(
                  'There is a new version of FlutterMatic, version ${_version?.substring(1) ?? 'UNKNOWN'} is the latest and you are using version $appVersion-$appBuild',
                  type: InformationType.green),
              VSeparators.normal(),
              RoundContainer(
                color: Colors.blueGrey.withOpacity(0.2),
                child: Row(
                  children: <Widget>[
                    Container(width: 2, height: 20, color: kGreenColor),
                    HSeparators.small(),
                    Expanded(
                      child: Text(
                          'Download the latest version of FlutterMatic - ${_version ?? 'UNKNOWN'}'),
                    ),
                  ],
                ),
              ),
              VSeparators.normal(),
              if (_updating)
                const CustomLinearProgressIndicator(includeBox: false)
              else
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
                        color: kGreenColor.withOpacity(
                            context.read<ThemeChangeNotifier>().isDarkTheme
                                ? 1
                                : 0.7),
                        child: const Text('Download',
                            style: TextStyle(color: Colors.black)),
                        onPressed: () async {
                          try {
                            setState(() => _updating = true);

                            // Will download and extract the [widget.downloadUrl].
                            // After that is done, it will get the path where the
                            // app code is and replace the entire folder with the
                            // downloaded one.
                            // After that, it will then close the app and restart
                            // it using the new code.
                            // Downloads to the C:\\fluttermatic\\fm_update\\ folder.
                            String _downloadPath =
                                '${context.read<SpaceCheck>().drive}:\\fluttermatic';

                            await Directory(_downloadPath)
                                .create(recursive: true);

                            await context.read<DownloadNotifier>().downloadFile(
                                widget.downloadUrl!,
                                'fm_update-$_version'.replaceAll('.', '-') +
                                    '.zip',
                                _downloadPath);

                            await logger.file(LogTypeTag.info,
                                'FlutterMatic update version $_version has been downloaded. Extracting...');

                            setState(() => _updating = false);

                            // Will open the folder viewer to show the downloaded
                            // updated.
                            switch (Platform.operatingSystem) {
                              case 'windows':
                                await Process.run(
                                    'explorer', <String>[_downloadPath]);
                                break;
                              case 'linux':
                                await Process.run(
                                    'xdg-open', <String>[_downloadPath]);
                                break;
                              case 'macos':
                                await Process.run(
                                    'open', <String>[_downloadPath]);
                                break;
                            }

                            Navigator.pop(context);

                            await showDialog(
                              context: context,
                              builder: (_) => _UpdateInstructionsDialog(
                                  downloadPath: _downloadPath),
                            );

                            return;
                          } catch (_, s) {
                            await logger.file(LogTypeTag.error,
                                'Failed to update FlutterMatic to version $_version: $_',
                                stackTraces: s);
                            setState(() => _updating = false);
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              snackBarTile(
                                context,
                                'Failed to download update. Please try again or download update manually from GitHub.',
                                action: snackBarAction(
                                  text: 'GitHub',
                                  onPressed: () => launch(widget.downloadUrl!),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpdateInstructionsDialog extends StatelessWidget {
  final String downloadPath;

  const _UpdateInstructionsDialog({
    Key? key,
    required this.downloadPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String _appPath =
        (Platform.resolvedExecutable.split('\\')..removeLast()).join('\\');
    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
            context, 'Please complete the update process.',
            type: SnackBarType.warning));
        return false;
      },
      child: DialogTemplate(
        onExit: () {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
              context, 'Please complete the update process.',
              type: SnackBarType.warning));
        },
        child: Column(
          children: <Widget>[
            const DialogHeader(title: 'Replace Files', canClose: false),
            informationWidget(
                'The zip folder containing the update has been downloaded to the folder: $downloadPath (We tried to open it for you. If it didn\'t open, please open it manually).',
                type: InformationType.green),
            VSeparators.normal(),
            RoundContainer(
              color: Colors.blueGrey.withOpacity(0.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'We get it! Why wouldn\'t you just do the whole update repair thing for me?',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  VSeparators.small(),
                  const Text(
                    'Ehm ehm, well... It\'s kind of complicated, but it\'s simple, trust me! Here is what you need to do:',
                    style: TextStyle(color: Colors.grey),
                  ),
                  VSeparators.normal(),
                  ...<String>[
                    '1 Screenshot this screen because you will need to close this app',
                    '2 Open the downloaded zip folder',
                    '3 Extract the zip folder to the same directory',
                    '4 Delete the zip folder',
                    '5 Rename the extracted folder to "fluttermatic" (or whatever you want to call it)',
                    '6 Close the FlutterMatic app',
                    '7 Delete the folder at this path: $_appPath',
                    '8 Open the extracted folder',
                    '9 Open the FlutterMatic app (fluttermatic.exe)',
                  ].map(
                    (String s) {
                      return Padding(
                        padding:
                            EdgeInsets.only(bottom: s.startsWith('9') ? 0 : 10),
                        child: Row(
                          children: <Widget>[
                            Text(
                              s.substring(0, 1) + '. ',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            HSeparators.xSmall(),
                            Expanded(
                              child: Text(
                                s.substring(2),
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            VSeparators.normal(),
            RectangleButton(
              width: double.infinity,
              child: const Text('Close FlutterMatic'),
              onPressed: () => exit(0),
            ),
          ],
        ),
      ),
    );
  }
}
