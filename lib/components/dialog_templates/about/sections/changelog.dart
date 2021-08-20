import 'package:flutter/material.dart';
import 'package:manager/core/libraries/widgets.dart';

class ChangelogAboutSection extends StatelessWidget {
  const ChangelogAboutSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Changelog',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 15),
        RoundContainer(
          color: Colors.blueGrey.withOpacity(0.2),
          width: double.infinity,
          child: const SelectableText(
            // TODO(yahu1031): Add the version for the current release as a constant.
            'FlutterMatic Installer Version // Version - Stable',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 15),
        //TODO(yahu1031): Add markdown for changelog in about page.
      ],
    );
  }
}
