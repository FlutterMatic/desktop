import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/widgets.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabViewTabHeadline(
      title: 'About',
      content: <Widget>[
        informationWidget(
          'FlutterMatic entirely relies on people who contributed to this project. As a way of showing appreciation, we are listing the name of the most active contributors.',
          type: InformationType.green,
        ),
        VSeparators.small(),
        infoWidget(
          context,
          'This project is completely open-source and can be found on GitHub.',
        ),
      ],
    );
  }
}
