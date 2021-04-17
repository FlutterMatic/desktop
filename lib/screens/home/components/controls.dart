import 'package:flutter/material.dart';
import 'package:flutter_installer/components/rectangle_button.dart';
import 'package:flutter_installer/components/round_container.dart';
import 'package:flutter_installer/components/title_section.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

Widget controls() {
  return SizedBox(
    width: 450,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        titleSection(
            'Controls', const Icon(Iconsdata.settings), () {}, 'Settings'),
        const SizedBox(height: 20),
        RoundContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Text(
                    'Channel',
                    style: TextStyle(fontSize: 18),
                  ),
                  const Spacer(),
                  const Icon(Iconsdata.channel),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Container(height: 20, width: 2, color: Colors.black),
                  const SizedBox(width: 10),
                  const Text(
                    'Stable - Version 2.0.1',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  RectangleButton(
                    onPressed: () {},
                    child: Row(
                      children: <Widget>[
                        const Text('Channel'),
                        const Spacer(),
                        const Icon(Iconsdata.changeChannel, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  RectangleButton(
                    onPressed: () {},
                    child: Row(
                      children: <Widget>[
                        const Text('Upgrade'),
                        const Spacer(),
                        const Icon(Iconsdata.rocket, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        RoundContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Examples',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              const SelectableText(
                'Interested in learning more about Flutter? There is a wide collection of open-source examples! You can check their source code in GitHub and learn new things you can do with Flutter.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: RectangleButton(
                  width: 150,
                  onPressed: () => launch('https://flutter.dev/docs'),
                  child: Row(
                    children: <Widget>[
                      const Text('Examples'),
                      const Spacer(),
                      const Icon(Iconsdata.examples, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
