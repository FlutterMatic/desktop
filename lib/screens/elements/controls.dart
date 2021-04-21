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
  return Column(
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
            const Text('Software Development Kits',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              children: [
                //Flutter
                Expanded(
                  child: ControlResourceTile(
                    flutterInstalled
                        ? 'Flutter ${flutterChannel![0].toUpperCase() + flutterChannel!.substring(1)}'
                        : 'Install Flutter',
                    flutterVersion,
                    [
                      if (flutterInstalled)
                        Expanded(
                          child: RectangleButton(
                            radius: BorderRadius.circular(5),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (context) => ChangeChannelDialog(),
                            ),
                            child: _controlButton(
                                'Channel', Iconsdata.changeChannel, context),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RectangleButton(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => flutterInstalled
                                ? CheckFlutterVersionDialog()
                                : InstallFlutterDialog(),
                          ),
                          child: _controlButton(
                              'Upgrade', Iconsdata.rocket, context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                //Java
                Expanded(
                  child: ControlResourceTile(
                    flutterInstalled ? 'Java' : 'Install Java',
                    javaVersion,
                    [
                      Expanded(
                        child: RectangleButton(
                          onPressed: () {},
                          child: _controlButton(
                              'Update', Iconsdata.rocket, context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('IDE Tools',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              children: [
                //VSCode
                Expanded(
                  child: ControlResourceTile(
                    flutterInstalled ? 'Visual Studio Code' : 'Install VSCode',
                    vscodeVersion,
                    [
                      Expanded(
                        child: RectangleButton(
                          onPressed: () {},
                          child: _controlButton('Open', Iconsdata.folder, context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SquareButton(
                        icon: Icon(
                          Iconsdata.browser,
                          color: customTheme.textTheme.bodyText1!.color,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                //Android Studio
                Expanded(
                  child: ControlResourceTile(
                    flutterInstalled
                        ? 'Android Studio'
                        : 'Install Android Studio',
                    androidSVersion,
                    [
                      Expanded(
                        child: RectangleButton(
                          onPressed: () {},
                          child: _controlButton('Emulator', null, context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RectangleButton(
                          onPressed: () {},
                          child:
                              _controlButton('Open', Iconsdata.folder, context),
                        ),
                      ),
                    ],
                  ),
                ),
                if (Platform.isMacOS) const SizedBox(width: 15),
                //XCode
                if (Platform.isMacOS)
                  Expanded(
                    child: ControlResourceTile(
                      flutterInstalled ? 'Xcode' : 'Install Xcode',
                      xcodeVersion,
                      [
                        Expanded(
                          child: RectangleButton(
                            onPressed: () {},
                            child: _controlButton('Open', null, context),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

class ControlResourceTile extends StatelessWidget {
  final String header;
  final String? version;
  final List<Widget>? actions;

  ControlResourceTile(this.header, this.version, this.actions);

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return RoundContainer(
      radius: 5,
      color: customTheme.buttonColor.withOpacity(0.5),
      height: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            header,
            softWrap: true,
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade,
            style: TextStyle(
                color: customTheme.textTheme.bodyText1!.color, fontSize: 15),
          ),
          Expanded(
              child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              version != null ? ('v' + version!) : 'Unknown Version',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            ),
          )),
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: actions!),
        ],
      ),
    );
  }
}

Widget _controlButton(String title, IconData? icon, BuildContext context) {
  ThemeData customTheme = Theme.of(context);
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Text(
        title,
        softWrap: false,
        overflow: TextOverflow.fade,
        style: TextStyle(
            fontSize: 15, color: customTheme.textTheme.bodyText1!.color),
      ),
      if (icon != null) const SizedBox(width: 10),
      if (icon != null)
        Icon(icon, color: customTheme.textTheme.bodyText1!.color, size: 20),
    ],
  );
}
