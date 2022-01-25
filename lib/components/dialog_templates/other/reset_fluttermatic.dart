// 🎯 Dart imports:
import 'dart:io';
import 'dart:math';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/inputs/text_field.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/shimmer.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/core/libraries/components.dart';
import 'package:fluttermatic/core/libraries/notifiers.dart';
import 'package:fluttermatic/core/libraries/services.dart';
import 'package:fluttermatic/core/libraries/utils.dart';
import 'package:fluttermatic/main.dart';

class ResetFlutterMaticDialog extends StatefulWidget {
  const ResetFlutterMaticDialog({Key? key}) : super(key: key);

  @override
  _ResetFlutterMaticDialogState createState() =>
      _ResetFlutterMaticDialogState();
}

class _ResetFlutterMaticDialogState extends State<ResetFlutterMaticDialog> {
  String _verificationTxt = '';

  bool _loading = true;
  final TextEditingController _confirmController = TextEditingController();

  Future<void> _beginDelete() async {
    try {
      setState(() => _loading = true);

      await logger.file(
          LogTypeTag.info, 'FlutterMatic was restarted and deleted all data.');

      Directory _appData = await getApplicationSupportDirectory();

      if (await _appData.exists()) {
        await _appData.delete(recursive: true);
      }

      Directory _downloadedTools =
          Directory(context.read<SpaceCheck>().drive + '\\fluttermatic');

      if (await _downloadedTools.exists()) {
        await _downloadedTools.delete(recursive: true);
      }

      await SharedPref().pref.clear();

      // Restart the app.
      RestartWidget.restartApp(context);

      setState(() => _loading = false);
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Failed to delete app data: $_',
          stackTraces: s);

      setState(() => _loading = false);
    }
  }

  Future<void> _loadData() async {
    await logger.file(LogTypeTag.warning, 'Reset FlutterMatic dialog opened');

    setState(() {
      _loading = false;
      _verificationTxt = kReleaseMode ? generateRandomString(10) : 'DEV_MODE';
    });
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: DialogTemplate(
        outerTapExit: false,
        child: Shimmer.fromColors(
          enabled: _loading,
          child: AnimatedOpacity(
            opacity: _loading ? 0.8 : 1,
            duration: const Duration(seconds: 3),
            child: IgnorePointer(
              ignoring: _loading,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const DialogHeader(
                      title: 'Reset FlutterMatic', canClose: false),
                  informationWidget(
                    'You are about to completely reset FlutterMatic. This will delete all your data and settings including Flutter, IDE\'s, Git and anything else that was installed by FlutterMatic. You will still be able to reinstall all of these again.',
                    type: InformationType.error,
                  ),
                  VSeparators.normal(),
                  Text(
                    'To verify this action, please enter the following code: $_verificationTxt',
                  ),
                  VSeparators.normal(),
                  CustomTextField(
                    hintText: 'Confirm',
                    controller: _confirmController,
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
                          color: AppTheme.errorColor,
                          child: const Text('DELETE'),
                          onPressed: () async {
                            if (_confirmController.text != _verificationTxt) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBarTile(
                                context,
                                'Please confirm by verifying the messages. This is very sensitive and cannot be undone.',
                                type: SnackBarType.error,
                              ));
                            } else {
                              // ignore: unawaited_futures
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (_) => DialogTemplate(
                                  width: 300,
                                  outerTapExit: false,
                                  child: hLoadingIndicator(),
                                ),
                              );

                              await _beginDelete();

                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String generateRandomString(int i) {
  const String _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  Random _rnd = Random();

  String getRandomString(int length) =>
      String.fromCharCodes(Iterable<int>.generate(
          length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  return getRandomString(i);
}
