// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/core/libraries/widgets.dart';

class LowDriveSpaceDialog extends StatefulWidget {
  const LowDriveSpaceDialog({Key? key}) : super(key: key);

  @override
  _LowDriveSpaceDialogState createState() => _LowDriveSpaceDialogState();
}

class _LowDriveSpaceDialogState extends State<LowDriveSpaceDialog> {
  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      outerTapExit: false,
      child: Column(
        children: const <Widget>[
          DialogHeader(title: 'No Space'),
        ],
      ),
    );
  }
}
