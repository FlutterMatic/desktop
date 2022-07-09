// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/space.dart';
import 'package:fluttermatic/core/notifiers/notifiers/general/space.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
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
    return Consumer(
      builder: (_, ref, __) {
        SpaceState spaceState = ref.watch(spaceStateController);

        SpaceNotifier spaceNotifier = ref.watch(spaceStateController.notifier);

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
                  'You will need at least ${spaceState.warnLessThanGB} GB of storage space to continue. This storage space will make sure that Flutter and all other tools can be installed locally. We will try our best to manage your space usage.',
                  type: InformationType.error,
                ),
                VSeparators.normal(),
                RectangleButton(
                  loading: _loading,
                  width: double.infinity,
                  child: const Text('Refresh'),
                  onPressed: () async {
                    setState(() => _loading = true);

                    await spaceNotifier.checkSpace();

                    if (mounted) {
                      RestartWidget.restartApp(context);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
