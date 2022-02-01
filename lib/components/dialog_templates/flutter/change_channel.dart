// 🎯 Dart imports:
import 'dart:developer';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/buttons/select_tiles.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/load_activity_msg.dart';
import 'package:fluttermatic/components/widgets/ui/shimmer.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/components/widgets/ui/stage_tile.dart';
import 'package:fluttermatic/core/models/check_response.model.dart';
import 'package:fluttermatic/core/notifiers/notifications.notifier.dart';
import 'package:fluttermatic/core/services/checks/check.services.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/main.dart';

class ChangeFlutterChannelDialog extends StatefulWidget {
  const ChangeFlutterChannelDialog({Key? key}) : super(key: key);

  @override
  _ChangeFlutterChannelDialogState createState() =>
      _ChangeFlutterChannelDialogState();
}

class _ChangeFlutterChannelDialogState
    extends State<ChangeFlutterChannelDialog> {
  // Inputs
  String? _selectedChannel;

  // Utils
  bool _switching = false;
  bool _initializing = true;
  String? _currentChannel;

  // UI
  String _activityMessage = '';

  Future<void> _switchChannels() async {
    try {
      setState(() => _switching = true);

      await shell
          .run('flutter channel $_selectedChannel')
          .asStream()
          .listen((List<ProcessResult> event) {
        if (mounted) {
          setState(() => _activityMessage =
              event.last.stdout.toString().split('\n').first);
        }
      }).asFuture();

      await CheckServices.checkFlutter();

      Navigator.pop(context);
      RestartWidget.restartApp(context);

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        snackBarTile(
          context,
          'Channel successfully switched to $_selectedChannel',
          type: SnackBarType.done,
        ),
      );

      await context.read<NotificationsNotifier>().newNotification(
            NotificationObject(
              Timeline.now.toString(),
              title: 'Flutter channel switched',
              message:
                  'Your Flutter channel was successfully switched to $_selectedChannel from $_currentChannel',
              onPressed: null,
            ),
          );
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Error switching channels: $_',
          stackTraces: s);

      setState(() => _switching = false);

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
        context,
        'Failed to switch from $_currentChannel to $_selectedChannel. Please try again.',
        type: SnackBarType.error,
      ));
    }
  }

  // Loads the current channel to avoid switching to the same channel.
  Future<void> _loadChannel() async {
    try {
      ServiceCheckResponse _result = await CheckServices.checkFlutter();

      String _channelCased = _result.channel!.substring(0, 1).toUpperCase() +
          _result.channel!.substring(1);

      await Future<void>.delayed(const Duration(seconds: 10));

      if (mounted) {
        setState(() {
          _initializing = false;
          _currentChannel = _channelCased;
          _selectedChannel = _channelCased;
        });
      }
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Error loading channel for channel switching: $_',
          stackTraces: s);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
        context,
        'Failed to load channel options. Please try again.',
        type: SnackBarType.error,
      ));

      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    _loadChannel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_switching,
      child: DialogTemplate(
        outerTapExit: false,
        child: Shimmer.fromColors(
          enabled: _initializing,
          child: IgnorePointer(
            ignoring: _initializing || _switching,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                DialogHeader(
                  title: 'Change Channel',
                  leading: const StageTile(),
                  canClose: !_switching,
                ),
                const Text(
                  'Choose a new channel to switch to. Switching to a new channel may take a while. New resources will be installed on your device. We recommend staying on the stable channel.',
                  style: TextStyle(fontSize: 13),
                ),
                VSeparators.normal(),
                SelectTile(
                  onPressed: (String val) =>
                      setState(() => _selectedChannel = val),
                  defaultValue: _selectedChannel,
                  options: const <String>['Master', 'Stable', 'Beta', 'Dev'],
                ),
                VSeparators.small(),
                AnimatedOpacity(
                  opacity: _initializing ? 0.1 : 1,
                  duration: const Duration(milliseconds: 300),
                  child: informationWidget(
                    'We recommend staying on the stable channel for best development experience unless it\'s necessary.',
                    type: InformationType.warning,
                  ),
                ),
                VSeparators.small(),
                if (_switching)
                  LoadActivityMessageElement(message: _activityMessage)
                else
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: RectangleButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      HSeparators.normal(),
                      Expanded(
                        child: RectangleButton(
                          child: const Text('Continue'),
                          onPressed: () {
                            if (_currentChannel == _selectedChannel) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  snackBarTile(context,
                                      'You are already on $_currentChannel channel. Select a different channel to continue.'));
                              return;
                            } else {
                              _switchChannels();
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
      ),
    );
  }
}
