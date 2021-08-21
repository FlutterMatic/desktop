import 'package:flutter/material.dart';
import 'package:manager/core/libraries/widgets.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'About',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        informationWidget(
          'FlutterMatic entirely relies on people who contributed to this project. As a way of showing appreciation, we are listing the name of the most active contributors.',
          type: InformationType.green,
        ),
        const SizedBox(height: 5),
        infoWidget(
          context,
          'This project is completely open-source and can be found on GitHub.',
        ),
      ],
    );
  }
}
