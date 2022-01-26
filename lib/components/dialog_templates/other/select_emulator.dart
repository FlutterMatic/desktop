// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';

class SelectEmulatorDialog extends StatelessWidget {
  const SelectEmulatorDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: const <Widget>[
          DialogHeader(title: 'Select Emulator'),
          // TODO: Implement an emulator selection interface
        ],
      ),
    );
  }
}
