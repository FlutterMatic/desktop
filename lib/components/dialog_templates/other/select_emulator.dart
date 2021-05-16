import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/dialog_header.dart';
import 'package:flutter_installer/components/widgets/dialog_template.dart';

class SelectEmulatorDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          DialogHeader(title: 'Select Emulator'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
