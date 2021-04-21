import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/general/change_channel.dart';
import 'package:flutter_installer/components/dialog_templates/general/flutter_upgrade.dart';
import 'package:flutter_installer/components/dialog_templates/general/install_fluter.dart';
import 'package:flutter_installer/components/dialog_templates/settings/control_settings.dart';
import 'package:flutter_installer/components/widgets/rectangle_button.dart';
import 'package:flutter_installer/components/widgets/round_container.dart';
import 'package:flutter_installer/components/widgets/square_button.dart';
import 'package:flutter_installer/components/widgets/title_section.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'dart:io';

Widget controls(BuildContext context) {
  ThemeData customTheme = Theme.of(context);
  Widget _divider() => Container(
      width: double.infinity,
      height: 1,
      color: customTheme.textTheme.bodyText1!.color!.withOpacity(0.3));

  return SizedBox(
    width: 500,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleSection(
          'Controls',
          Icon(Icons.settings, color: customTheme.iconTheme.color),
          () {
            showDialog(
              context: context,
              builder: (_) => ControlSettings(),
            );
          },
          context: context,
        ),
        const SizedBox(height: 20),
        RoundContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    'Channels & Versions',
                    style: TextStyle(
                      fontSize: 18,
                      color: customTheme.textTheme.bodyText1!.color,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Iconsdata.channel),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  //Flutter
                  Expanded(
                    child: ControlResourceTile(
                      flutterInstalled
                          ? 'Flutter ${flutterChannel![0].toUpperCase() + flutterChannel!.substring(1)} - Version $flutterVersion'
                          : 'Install Flutter',
                      [
                        if (flutterInstalled)
                          RectangleButton(
                            radius: BorderRadius.circular(5),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (context) => ChangeChannelDialog(),
                            ),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  'Channel',
                                  style: TextStyle(
                                    color:
                                        customTheme.textTheme.bodyText1!.color,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Iconsdata.changeChannel,
                                  size: 20,
                                  color: customTheme.iconTheme.color,
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(width: 8),
                        RectangleButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => flutterInstalled
                                  ? CheckFlutterVersionDialog()
                                  : InstallFlutterDialog(),
                            );
                          },
                          child: Row(
                            children: <Widget>[
                              Text(
                                'Upgrade',
                                style: TextStyle(
                                  color: customTheme.textTheme.bodyText1!.color,
                                ),
                              ),
                              const Spacer(),
                              Icon(Iconsdata.rocket,
                                  size: 20, color: customTheme.iconTheme.color),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  //Java
                  Expanded(
                    child: ControlResourceTile(
                      flutterInstalled
                          ? 'Java - Version $javaVersion'
                          : 'Install Java',
                      [
                        SquareButton(
                            icon: const Icon(Iconsdata.rocket),
                            onPressed: () {})
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _divider(),
              const SizedBox(height: 10),
              Row(
                children: [
                  //VS Code
                  Expanded(
                    child: ControlResourceTile(
                      flutterInstalled
                          ? 'VSCode - Version $vscodeVersion'
                          : 'Install VSCode',
                      [
                        SquareButton(
                            icon: const Icon(Iconsdata.rocket),
                            onPressed: () {})
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  //Android Studio
                  Expanded(
                    child: ControlResourceTile(
                      flutterInstalled
                          ? 'Android Studio - Version $androidSVersion'
                          : 'Install Android Studio',
                      [
                        SquareButton(
                            icon: const Icon(Iconsdata.rocket),
                            onPressed: () {})
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _divider(),
              const SizedBox(height: 10),
              //XCode
              if (!Platform.isMacOS)
                ControlResourceTile(
                  flutterInstalled
                      ? 'Xcode - Version $xcodeVersion'
                      : 'Install Xcode',
                  [
                    SquareButton(
                        icon: const Icon(Iconsdata.rocket), onPressed: () {})
                  ],
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

class ControlResourceTile extends StatefulWidget {
  final String message;
  final List<Widget>? actions;

  ControlResourceTile(this.message, this.actions);

  @override
  _ControlResourceTileState createState() => _ControlResourceTileState();
}

class _ControlResourceTileState extends State<ControlResourceTile> {
  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return RoundContainer(
      radius: 5,
      color: Colors.blueGrey.withOpacity(0.1),
      height: 150,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Text(widget.message,
                softWrap: true,
                overflow: TextOverflow.fade,
                style:
                    TextStyle(color: customTheme.textTheme.bodyText1!.color)),
          ),
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.actions!),
        ],
      ),
    );
  }
}
