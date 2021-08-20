import 'package:flutter/material.dart';
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
        children: <Widget>[
          const Text('Storage Full'),
        ],
      ),
    );
  }
}
