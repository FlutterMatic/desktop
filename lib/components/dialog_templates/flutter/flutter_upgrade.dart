// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/core/libraries/widgets.dart';
import '../dialog_header.dart';

class UpgradeFlutterDialog extends StatefulWidget {
  const UpgradeFlutterDialog({Key? key}) : super(key: key);

  @override
  _UpgradeFlutterDialogState createState() => _UpgradeFlutterDialogState();
}

class _UpgradeFlutterDialogState extends State<UpgradeFlutterDialog> {
  /// TODO: Upgrade Flutter when is requested. Ignore the request and say that Flutter is already up to date if current version is equal to the latest version.
  Future<void> _upgradeFlutter() async {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      snackBarTile(
        context,
        'Checking and upgrading your Flutter version.',
        type: SnackBarType.done,
      ),
    );

    List<ProcessResult> _versionInfo = await shell.run('flutter --version');

    // String _version = _versionInfo.first.stdout.toString().split(' ')[1];
    String _channel = _versionInfo.first.stdout.toString().split(' ')[4];
    String _flutterUrl = 'https://github.com/flutter/flutter';

    // Get the latest commit hash from the branch of [channel].
    String _latestCommitHash =
        await getRepoCommitHash(branchName: _channel, url: _flutterUrl);

    print(_latestCommitHash);

    // Compare the current Flutter on the system commit hash with the latest
    // commit hash from the branch of [channel].
    List<ProcessResult> _currentBranchInfo =
        await shell.run('git rev-parse --abbrev-ref HEAD');

    String _currentCommitHash = _currentBranchInfo.first.stdout.toString();

    print(_currentCommitHash);

    // Latest version already.
    if (_currentCommitHash == _latestCommitHash) {
    } else {}

    // Navigator.pop(context);

    // BgActivityTile _tile = BgActivityTile(
    //   title: 'Upgrading your Flutter version',
    //   activityId: Timeline.now.toString(),
    // );

    // setState(() => bgActivities.add(_tile));

    // setState(() => bgActivities.remove(_tile));

    // Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const DialogHeader(title: 'Upgrade Flutter'),
          const Text(
            'Keeping Flutter up-to-date is a good idea since it helps with many things including performance improvements, bug fixes and new features.',
            textAlign: TextAlign.center,
          ),
          VSeparators.small(),
          infoWidget(context,
              'You can still use Flutter in your IDE while we update. You will be asked to restart any opened editors once the update is complete.'),
          VSeparators.small(),
          RectangleButton(
            width: double.infinity,
            onPressed: _upgradeFlutter,
            child: const Text('Upgrade Flutter'),
          ),
        ],
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
    await logger.file(LogTypeTag.error, 'Could not get commit hash from $url: $_',
        stackTraces: s);
    return 'unknown';
  }

  String _hash = _cmdResult[0].stdout.split('\t')[0];

  return _hash;
}
