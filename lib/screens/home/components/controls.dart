import 'package:flutter/material.dart';
import 'package:flutter_installer/components/rectangle_button.dart';
import 'package:flutter_installer/components/round_container.dart';
import 'package:flutter_installer/components/square_button.dart';
import 'package:flutter_installer/components/title_section.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

Widget controls() {
  return SizedBox(
    width: 450,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        titleSection('Controls', const Icon(Icons.settings), () {}, 'Settings'),
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
                  SvgPicture.asset(Assets.channels),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(height: 20, width: 1, color: Colors.grey),
                  const SizedBox(width: 10),
                  const Text('Stable - Version 2.0.1',
                      style: TextStyle(color: Colors.black54)),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  SquareButton(
                      color: kLightGreyColor,
                      icon: const Icon(Icons.settings),
                      tooltip: 'Settings',
                      onPressed: () {}),
                  const SizedBox(width: 10),
                  RectangleButton(
                    onPressed: () {},
                    child: Row(
                      children: <Widget>[
                        const Text('Upgrade'),
                        const Spacer(),
                        SvgPicture.asset(Assets.upgrade),
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
                      const Text('Open Examples'),
                      const Spacer(),
                      const Icon(Icons.open_in_new_rounded, size: 20),
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
