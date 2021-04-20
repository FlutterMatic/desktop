import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/change_channel.dart';
import 'package:flutter_installer/components/dialog_templates/flutter_upgrade.dart';
import 'package:flutter_installer/components/dialog_templates/install_fluter.dart';
import 'package:flutter_installer/components/rectangle_button.dart';
import 'package:flutter_installer/components/round_container.dart';
import 'package:flutter_installer/components/title_section.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

Widget controls(BuildContext context) {
  ThemeData customTheme = Theme.of(context);
  return SizedBox(
    width: 500,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleSection(
          'Controls',
          Icon(Icons.settings, color: customTheme.iconTheme.color),
          () {},
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
                    'Channel',
                    style: TextStyle(
                      fontSize: 18,
                      color: customTheme.textTheme.bodyText1!.color,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Iconsdata.channel),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Container(
                    height: 20,
                    width: 2,
                    color: customTheme.dividerColor,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    flutterInstalled
                        ? '${flutterChannel![0].toUpperCase() + flutterChannel!.substring(1)} - Version $flutterVersion'
                        : 'Install flutter first',
                    style: TextStyle(
                      color: customTheme.textTheme.bodyText1!.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  if (flutterInstalled)
                    RectangleButton(
                      radius: BorderRadius.circular(5),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => ChangeChannelDialog(),
                      ),
                      width: 110,
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Channel',
                            style: TextStyle(
                              color: customTheme.textTheme.bodyText1!.color,
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
                        //Upgrade Flutter Models:
                        //`NewFlutterDialog()` => Informs user there is a new Flutter version
                        //`CheckFlutterVersionDialog()` => Informs user that it's checking for the latest version
                        //`LatestFlutterDialog()` => Informs the user that you are on the latest version
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
                        Icon(
                          Iconsdata.rocket,
                          size: 20,
                          color: customTheme.iconTheme.color,
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
    ),
  );
}

Widget examplesTile(BuildContext context) {
  ThemeData customTheme = Theme.of(context);
  return RoundContainer(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Examples',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 10),
        SelectableText(
          'Interested in learning more about Flutter? There is a wide collection of open-source examples! You can check their source code in GitHub and learn new things you can do with Flutter.',
          style: TextStyle(
            fontSize: 14,
            color: customTheme.textTheme.bodyText1!.color,
          ),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: Tooltip(
            message: 'Open in Browser',
            child: RectangleButton(
              width: 110,
              onPressed: () => launch('https://flutter.github.io/samples/'),
              child: Row(
                children: <Widget>[
                  Text(
                    'Examples',
                    style: TextStyle(
                      color: customTheme.textTheme.bodyText1!.color,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Iconsdata.examples,
                    size: 20,
                    color: customTheme.iconTheme.color,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

enum FlutterChannel { beta, stable, dev }
