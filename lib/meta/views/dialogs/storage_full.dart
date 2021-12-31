// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/core/libraries/constants.dart';
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
          const DialogHeader(title: 'No Space', canClose: false),
          const Text(
            'You don\'t have enough space on your drive space left. Please free up some space to continue.',
            textAlign: TextAlign.center,
          ),
          VSeparators.normal(),
          const Divider(height: 1, color: Colors.grey),
          VSeparators.normal(),
          const Text(
            'You will need at least a couple gigabytes of space to continue. We will try our best to manage your space usage.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          VSeparators.normal(),
          RectangleButton(
            width: double.infinity,
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
