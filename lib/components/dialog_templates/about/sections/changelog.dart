import 'package:flutter/material.dart';
import 'package:flutter_installer/components/widgets/ui/round_container.dart';
import 'package:flutter_installer/utils/constants.dart';

class ChangelogAboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Changelog',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 15),
        RoundContainer(
          color: Colors.blueGrey.withOpacity(0.2),
          width: double.infinity,
          child: SelectableText(
            'FlutterMatic Installer Version $desktopVersion - Stable',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 15),
        //TODO(yahu1031): Add mardown for changlog in about page.
      ],
    );
  }
}
