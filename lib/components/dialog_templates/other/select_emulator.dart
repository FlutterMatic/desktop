import 'package:flutter/material.dart';
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/core/libraries/widgets.dart';

class SelectEmulatorDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          const DialogHeader(title: 'Select Emulator'),
          // TODO: Implement an emulator selection interface
        ],
      ),
    );
  }
}
