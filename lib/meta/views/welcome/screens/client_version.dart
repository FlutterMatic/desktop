import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/components/widgets/buttons/rectangle_button.dart';
import 'package:manager/components/widgets/ui/dialog_template.dart';
import 'package:manager/components/widgets/ui/info_widget.dart';
import 'package:manager/meta/utils/shared_pref.dart';

class ClientVersionDialog extends StatelessWidget {
  const ClientVersionDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const DialogHeader(
            title: 'Client Version',
          ),
          VSeparators.large(),
          infoWidget(context, '- Version: ${SharedPref().prefs.getString('App_Version')} (${SharedPref().prefs.getString('App_Build')!.toUpperCase()}) \n- $osName - $osVersion'),
          VSeparators.large(),
          RectangleButton(
            width: double.infinity,
            color: Colors.blueGrey,
            splashColor: Colors.blueGrey.withOpacity(0.5),
            focusColor: Colors.blueGrey.withOpacity(0.5),
            hoverColor: Colors.grey.withOpacity(0.5),
            highlightColor: Colors.blueGrey.withOpacity(0.5),
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
