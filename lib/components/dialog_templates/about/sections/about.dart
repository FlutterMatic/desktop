import 'package:flutter/material.dart';
import 'package:flutter_installer/components/widgets/ui/info_widget.dart';
import 'package:flutter_installer/components/widgets/ui/warning_widget.dart';
import 'package:flutter_installer/utils/constants.dart';

class AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        warningWidget(
          'FlutterMatic entirely relies on people who contributed to this project. As a way of showing appreciation, we are listing the name of the most active contributers.',
          Assets.done,
          kGreenColor,
          false,
        ),
        const SizedBox(height: 5),
        infoWidget(
          'This project is completely open-source and can be found on GitHub.',
        ),
      ],
    );
  }
}
