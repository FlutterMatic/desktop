import 'package:flutter/material.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/meta/utils/shared_pref.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/dialog_templates/dialog_header.dart';

class SystemRequirementsDialog extends StatefulWidget {
  const SystemRequirementsDialog({Key? key}) : super(key: key);

  @override
  _SystemRequirementsDialogState createState() =>
      _SystemRequirementsDialogState();
}

class _SystemRequirementsDialogState extends State<SystemRequirementsDialog> {
  String? platform = SharedPref().prefs.getString('platform');
  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      outerTapExit: false,
      closeBgColor: Colors.transparent,
      closeIconColor: kRedColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const DialogHeader(
            title: 'System Requirements',
            onHoverButtonColor: Colors.transparent,
          ),
          VSeparators.normal(),
          BulletPoint(
            platform == 'windows'
                ? SystemRequirementsContent.winOS
                : platform == 'macos'
                    ? SystemRequirementsContent.macOS
                    : SystemRequirementsContent.linuxOS,
          ),
          VSeparators.normal(),
          BulletPoint(
            platform == 'windows'
                ? SystemRequirementsContent.winSpace
                : platform == 'macos'
                    ? SystemRequirementsContent.macSpace
                    : SystemRequirementsContent.linuxSpace,
          ),
          VSeparators.normal(),
          BulletPoint(
            platform == 'windows'
                ? SystemRequirementsContent.winTools
                : platform == 'macos'
                    ? SystemRequirementsContent.macTools
                    : SystemRequirementsContent.linuxTools,
          ),
          VSeparators.normal(),
        ],
      ),
    );
  }
}
