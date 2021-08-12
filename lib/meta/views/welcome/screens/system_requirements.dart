import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/components/widgets/ui/bullet_point.dart';
import 'package:manager/components/widgets/ui/dialog_template.dart';

class SystemRequirementsDialog extends StatefulWidget {
  const SystemRequirementsDialog({Key? key}) : super(key: key);

  @override
  _SystemRequirementsDialogState createState() =>
      _SystemRequirementsDialogState();
}

class _SystemRequirementsDialogState extends State<SystemRequirementsDialog> {
  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          const DialogHeader(title: 'System Requirements'),
          VSeparators.normal(),
          BulletPoint('4 GB Ram'),
        ],
      ),
    );
  }
}
