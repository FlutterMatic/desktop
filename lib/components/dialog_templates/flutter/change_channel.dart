import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/dialog_header.dart';
import 'package:flutter_installer/components/widgets/ui/activity_tile.dart';
import 'package:flutter_installer/components/widgets/buttons/button_list.dart';
import 'package:flutter_installer/components/widgets/ui/dialog_template.dart';
import 'package:flutter_installer/components/widgets/ui/info_widget.dart';
import 'package:flutter_installer/components/widgets/buttons/rectangle_button.dart';
import 'package:flutter_installer/components/widgets/ui/spinner.dart';
import 'package:flutter_installer/components/widgets/ui/warning_widget.dart';
import 'package:flutter_installer/screens/home_screen.dart';
import 'package:flutter_installer/services/flutter_actions.dart';
import 'package:flutter_installer/utils/constants.dart';

class ChangeChannelDialog extends StatefulWidget {
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
      _loadingMaterials = channelIsUpdating;
      _selectedChannel = flutterChannel!.substring(0, 1).toUpperCase() +
          flutterChannel!.substring(1);
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
          ? SizedBox(height: 300, width: 300, child: Spinner())
          : _loadingMaterials
              ? _updatingChannels(context)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    DialogHeader(title: 'Change Channel'),
                    const SizedBox(height: 15),
                    const Text(
                      'Choose a new channel to switch to. Switching to a new channel may take a while. New resources will be installed on your machine. We recommned staying on the stable channel.',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 15),
                    SelectTile(
                      onPressed: (val) =>
                          setState(() => _selectedChannel = val),
                      defaultValue: _selectedChannel,
                      options: ['Master', 'Stable', 'Beta', 'Dev'],
                    ),
                    warningWidget(
                        'We recommend staying on the stable channel for best development experience unless it\'s necessary.',
                        Assets.warning,
                        kYellowColor),
                    const SizedBox(height: 10),
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
                            } else if (_selectedChannel ==
                                flutterChannel!.substring(0, 1).toUpperCase() +
                                    flutterChannel!.substring(1)) {
                              showDialog(
                                context: context,
                                builder: (_) => AlreadyChannelDialog(),
                              );
                            } else {
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
  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return DialogTemplate(
      outerTapExit: false,
      child: Column(
        children: <Widget>[
          DialogHeader(title: 'Same Channel', canClose: false),
          const SizedBox(height: 15),
          Text(
            'It looks like you are already in the $flutterChannel. You didn\'t mean to choose $flutterChannel? You can go back and pick another channel.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
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

  ConfirmChannelChangeDialog(this.channelName);

  @override
  Widget build(BuildContext context) {
    Future<void> _switchChannel() async {
      if (channelName != flutterChannel) {
        BgActivityTile element = BgActivityTile(
          title: 'Changing to $channelName channel',
          activityId: 'channel_switch_$channelName${Timeline.now}',
        );
        channelIsUpdating = true;
        bgActivities.add(element);
        if (win32) {
          await FlutterActions().changeChannel(channelName.toLowerCase());
        }
        channelIsUpdating = false;
        bgActivities.remove(element);
        Navigator.pop(context);
      }
    }

    return DialogTemplate(
      child: Column(
        children: <Widget>[
          DialogHeader(title: 'Change to $channelName'),
          const SizedBox(height: 15),
          const Text(
            'You will still be able to continue using the IDE with Flutter while we change channels. Please be aware that changing channels will take time.',
            textAlign: TextAlign.center,
          ),
          infoWidget(
              'This process may take some time. You will still be able to use Flutter in your IDE. Once switching channels, we recommend restarting any open editors.'),
          const SizedBox(height: 15),
          RectangleButton(
            width: double.infinity,
            color: Colors.blueGrey,
            splashColor: Colors.blueGrey.withOpacity(0.5),
            focusColor: Colors.blueGrey.withOpacity(0.5),
            hoverColor: Colors.grey.withOpacity(0.5),
            highlightColor: Colors.blueGrey.withOpacity(0.5),
            onPressed: () {
              _switchChannel();
              Navigator.pushNamed(context, HomeScreen.id);
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
      DialogHeader(title: 'In Progress'),
      const SizedBox(height: 15),
      const Text(
        'We are currently updating your Flutter channel. Please check back later once we are finished updating your Flutter channel.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13),
      ),
      const SizedBox(height: 20),
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
