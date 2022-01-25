// 🎯 Dart imports:
import 'dart:developer';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:fluttermatic/core/models/check_response.model.dart';
import 'package:fluttermatic/core/notifiers/notifications.notifier.dart';
import 'package:fluttermatic/core/services/checks/check.services.dart';

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

  String _activityMessage = '';

  Future<void> _upgradeFlutter() async {
    setState(() => _updating = true);

    // Make sure that there is an internet connection.
    if (!context.read<ConnectionNotifier>().isOnline) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
        context,
        'Please check your network connection first to update Flutter.',
        type: SnackBarType.error,
      ));
      setState(() => _updating = false);
      return;
    }

    // Already Updated Sample Response:
    // Flutter is already up to date on channel stable
    // Flutter 2.8.1 • channel stable • https://github.com/flutter/flutter.git
    // Framework • revision 77d935af4d (6 weeks ago) • 2021-12-16 08:37:33 -0800
    // Engine • revision 890a5fca2e
    // Tools • Dart 2.15.1

    await shell
        .run('flutter upgrade')
        .asStream()
        .listen((List<ProcessResult> event) {
          if (event.isNotEmpty && mounted) {
            setState(() => _activityMessage =
                event.last.stdout.toString().split('\n').first);
          }
        })
        .asFuture()
        .onError((Object? _, StackTrace s) {
          logger.file(LogTypeTag.error, 'Error while updating Flutter: $_',
              stackTraces: s);
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
            context,
            'Failed to update Flutter. Please make sure you have a stable network connection and try again.',
            type: SnackBarType.error,
          ));
          if (mounted) {
            setState(() =>
                _activityMessage = 'An error occurred while updating Flutter.');
          }
          return;
        });

    ServiceCheckResponse _result = await CheckServices.checkFlutter();

    await context.read<NotificationsNotifier>().newNotification(
          NotificationObject(
            Timeline.now.toString(),
            title:
                'Flutter has been updated to ${_result.version ?? 'UNKNOWN'}',
            message:
                'You have successfully updated your local Flutter version to ${_result.version ?? 'UNKNOWN'}.',
            onPressed: null,
          ),
        );

    if (mounted) {
      if (_activityMessage.toLowerCase().startsWith('flutter is already')) {
        await logger.file(LogTypeTag.info,
            'Flutter is already up to date on channel stable with version ${_result.version}. Attempted upgrade when no new version available.');
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
          context,
          'Flutter is already up to date on channel ${_result.channel}.',
          type: SnackBarType.done,
        ));
      } else {
        await logger.file(LogTypeTag.info,
            'Flutter has been updated to ${_result.version} on channel ${_result.channel}.');
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
          context,
          'Flutter has been updated to ${_result.version ?? 'UNKNOWN'} on channel ${_result.channel}.',
          type: SnackBarType.done,
        ));
      }

      Navigator.pop(context);
    }
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
            VSeparators.normal(),
            infoWidget(context,
                'You can still use Flutter in your IDE while we update. You will be asked to restart any opened editors once the update is complete. You can\'t use FlutterMatic while we update.'),
            VSeparators.small(),
            if (_updating)
              RoundContainer(
                child: Builder(
                  builder: (_) {
                    if (_activityMessage.isEmpty) {
                      return const CustomLinearProgressIndicator(
                          includeBox: false);
                    } else {
                      return Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(_activityMessage,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          HSeparators.small(),
                          const SizedBox(
                            width: 50,
                            child: CustomLinearProgressIndicator(
                                includeBox: false),
                          ),
                        ],
                      );
                    }
                  },
                ),
              )
            else
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
