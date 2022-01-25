// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/src/provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/core/libraries/notifiers.dart';
import 'package:fluttermatic/core/libraries/services.dart';
import 'package:fluttermatic/core/libraries/widgets.dart';
import '../dialog_header.dart';

class UpdateFlutterDialog extends StatefulWidget {
  const UpdateFlutterDialog({Key? key}) : super(key: key);

  @override
  _UpdateFlutterDialogState createState() => _UpdateFlutterDialogState();
}

class _UpdateFlutterDialogState extends State<UpdateFlutterDialog> {
  bool _updating = false;

  /// TODO: Update Flutter when is requested. Ignore the request and say that Flutter is already up to date if current version is equal to the latest version.
  Future<void> _upgradeFlutter() async {
    setState(() => _updating = true);

    // Make sure that there is an internet connection.
    if (context.read<ConnectionNotifier>().isOnline) {
      
    }

    // Already Updated Sample Response:
    // Flutter is already up to date on channel stable
    // Flutter 2.8.1 • channel stable • https://github.com/flutter/flutter.git
    // Framework • revision 77d935af4d (6 weeks ago) • 2021-12-16 08:37:33 -0800
    // Engine • revision 890a5fca2e
    // Tools • Dart 2.15.1

    await Future<void>.delayed(const Duration(seconds: 10));

    // Latest version already.
    setState(() => _updating = false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_updating,
      child: DialogTemplate(
        outerTapExit: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            DialogHeader(title: 'Update Flutter', canClose: !_updating),
            const Text(
              'Keeping Flutter up-to-date is a good idea since it helps with many things including performance improvements, bug fixes and new features.',
              textAlign: TextAlign.center,
            ),
            VSeparators.small(),
            infoWidget(context,
                'You can still use Flutter in your IDE while we update. You will be asked to restart any opened editors once the update is complete. You can\'t use FlutterMatic while we update.'),
            VSeparators.small(),
            RectangleButton(
              loading: _updating,
              width: double.infinity,
              onPressed: _upgradeFlutter,
              child: const Text('Check and Update Flutter'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String> getRepoCommitHash({
  required String url,
  required String branchName,
}) async {
  String _cmd = 'git ls-remote --heads $url.git refs/heads/$branchName';

  List<ProcessResult> _cmdResult;

  try {
    _cmdResult = await shell.run(_cmd);
  } catch (_, s) {
    await logger.file(
        LogTypeTag.error, 'Could not get commit hash from $url: $_',
        stackTraces: s);
    return 'unknown';
  }

  String _hash = _cmdResult[0].stdout.split('\t')[0];

  return _hash;
}
