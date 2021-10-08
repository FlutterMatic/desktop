// 🎯 Dart imports:
import 'dart:developer';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/meta/views/home/home.dart';

class ChangeChannelDialog extends StatefulWidget {
  const ChangeChannelDialog({Key? key}) : super(key: key);

  @override
  _ChangeChannelDialogState createState() => _ChangeChannelDialogState();
}

class _ChangeChannelDialogState extends State<ChangeChannelDialog> {
  //Inputs
  String? _selectedChannel;

  //Utils
  bool _loadingMaterials = true;
  bool _loading = true;

  void _loadChannel() {
    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    _loadChannel();
    super.initState();
  }

  @override
  void dispose() {
    _loadingMaterials = true;
    _loading = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return DialogTemplate(
      child: _loading
          ? const SizedBox(height: 300, width: 300, child: Spinner())
          : _loadingMaterials
              ? _updatingChannels(context)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const DialogHeader(title: 'Change Channel'),
                    const Text(
                      'Choose a new channel to switch to. Switching to a new channel may take a while. New resources will be installed on your device. We recommend staying on the stable channel.',
                      style: TextStyle(fontSize: 13),
                    ),
                    VSeparators.normal(),
                    SelectTile(
                      onPressed: (String val) =>
                          setState(() => _selectedChannel = val),
                      defaultValue: _selectedChannel,
                      options: const <String>[
                        'Master',
                        'Stable',
                        'Beta',
                        'Dev'
                      ],
                    ),
                    informationWidget(
                      'We recommend staying on the stable channel for best development experience unless it\'s necessary.',
                      type: InformationType.warning,
                    ),
                    VSeparators.small(),
                    Row(
                      children: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: Text('Cancel'),
                          ),
                        ),
                        const Spacer(),
                        RectangleButton(
                          width: 120,
                          onPressed: () {
                            if (_selectedChannel == null) {
                              Navigator.pop(context);
                            }
                            // TODO: Show the AlreadyChannelDialog if the user selected a channel that they are already currently in.
                            // showDialog(
                            //   context: context,
                            //   builder: (_) => AlreadyChannelDialog(),
                            // );
                            else {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (_) => ConfirmChannelChangeDialog(
                                    _selectedChannel!),
                              );
                            }
                          },
                          child: Text(
                            'Continue',
                            style: TextStyle(
                                color: customTheme.textTheme.bodyText1!.color),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }
}

class AlreadyChannelDialog extends StatelessWidget {
  const AlreadyChannelDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return DialogTemplate(
      outerTapExit: false,
      child: Column(
        children: <Widget>[
          const DialogHeader(title: 'Same Channel', canClose: false),
          const Text(
            // TODO: Show the channel name.
            'It looks like you are already in the // Channel //. You didn\'t mean to choose // Channel //? You can go back and pick another channel.',
            textAlign: TextAlign.center,
          ),
          VSeparators.large(),
          RectangleButton(
            width: double.infinity,
            color: customTheme.focusColor,
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(color: customTheme.textTheme.bodyText1!.color),
            ),
          ),
        ],
      ),
    );
  }
}

class ConfirmChannelChangeDialog extends StatelessWidget {
  final String channelName;

  const ConfirmChannelChangeDialog(this.channelName, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Create the function to switch the flutter channels.
    Future<void> _switchChannel() async {
      // First make sure that the requested channel is not the same as
      // the same channel the user is currently in.

      // Before starting, add the current activity of switching the channels
      // so the user can see the activity fo switching the channels.
      BgActivityTile _activityElement = BgActivityTile(
        title: 'Changing to $channelName channel',
        activityId: 'channel_switch_$channelName${Timeline.now}',
      );
      bgActivities.add(_activityElement);
      bgActivities.remove(_activityElement);
      Navigator.pop(context);
    }

    return DialogTemplate(
      child: Column(
        children: <Widget>[
          DialogHeader(title: 'Change to $channelName'),
          const Text(
            'You will still be able to continue using the IDE with Flutter while we change channels. Please be aware that changing channels will take time.',
            textAlign: TextAlign.center,
          ),
          infoWidget(context,
              'This process may take some time. You will still be able to use Flutter in your IDE. Once switching channels, we recommend restarting any open editors.'),
          VSeparators.normal(),
          RectangleButton(
            width: double.infinity,
            color: Colors.blueGrey,
            splashColor: Colors.blueGrey.withOpacity(0.5),
            focusColor: Colors.blueGrey.withOpacity(0.5),
            hoverColor: Colors.grey.withOpacity(0.5),
            highlightColor: Colors.blueGrey.withOpacity(0.5),
            onPressed: () async {
              await _switchChannel();
              await Navigator.push(
                context,
                MaterialPageRoute<Widget>(builder: (_) => const HomeScreen()),
              );
            },
            child: const Text('Change Channel'),
          ),
        ],
      ),
    );
  }
}

Widget _updatingChannels(BuildContext context) {
  ThemeData customTheme = Theme.of(context);
  return Column(
    children: <Widget>[
      const DialogHeader(title: 'In Progress'),
      const Text(
        'We are currently updating your Flutter channel. Please check back later once we are finished updating your Flutter channel.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13),
      ),
      VSeparators.large(),
      RectangleButton(
        width: double.infinity,
        onPressed: () => Navigator.pop(context),
        child: Text(
          'OK',
          style: TextStyle(color: customTheme.textTheme.bodyText1!.color),
        ),
      ),
    ],
  );
}
