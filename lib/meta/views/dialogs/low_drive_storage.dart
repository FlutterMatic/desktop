// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/core/libraries/constants.dart';
import 'package:fluttermatic/core/libraries/notifiers.dart';
import 'package:fluttermatic/core/libraries/widgets.dart';
import 'package:fluttermatic/main.dart';

class LowDriveSpaceDialog extends StatefulWidget {
  const LowDriveSpaceDialog({Key? key}) : super(key: key);

  @override
  _LowDriveSpaceDialogState createState() => _LowDriveSpaceDialogState();
}

class _LowDriveSpaceDialogState extends State<LowDriveSpaceDialog> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: DialogTemplate(
        outerTapExit: false,
        child: Column(
          children: <Widget>[
            const DialogHeader(title: 'Low on Space', canClose: false),
            const Text(
              'You don\'t have enough space on your drive left. Please free up some space to continue.',
              textAlign: TextAlign.center,
            ),
            VSeparators.normal(),
            const Divider(height: 1, color: Colors.grey),
            VSeparators.normal(),
            informationWidget(
              'You will need at least ${context.read<SpaceCheck>().warnLessThanGB} GB of storage space to continue. This storage space will make sure that Flutter and all other tools can be installed locally. We will try our best to manage your space usage.',
              type: InformationType.error,
            ),
            VSeparators.normal(),
            RectangleButton(
              loading: _loading,
              width: double.infinity,
              child: const Text('Refresh'),
              onPressed: () async {
                setState(() => _loading = true);
                await SpaceCheck().checkSpace();
                RestartWidget.restartApp(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
