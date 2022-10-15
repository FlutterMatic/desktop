// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/load_activity_msg.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/components/widgets/ui/stage_tile.dart';
import 'package:fluttermatic/core/notifiers/models/state/actions/flutter.dart';
import 'package:fluttermatic/core/notifiers/notifiers/actions/flutter.dart';
import 'package:fluttermatic/core/notifiers/out.dart';

class UpgradeFlutterDialog extends StatefulWidget {
  const UpgradeFlutterDialog({Key? key}) : super(key: key);

  @override
  State<UpgradeFlutterDialog> createState() => _UpgradeFlutterDialogState();
}

class _UpgradeFlutterDialogState extends State<UpgradeFlutterDialog> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        FlutterActionsState flutterActionState =
            ref.watch(flutterActionsStateNotifier);

        FlutterActionsNotifier flutterActionNotifier =
            ref.watch(flutterActionsStateNotifier.notifier);

        return DialogTemplate(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const DialogHeader(
                title: 'Update Flutter',
                leading: StageTile(),
              ),
              if (flutterActionState.error.isNotEmpty)
                informationWidget(
                  flutterActionState.error,
                  type: InformationType.error,
                ),
              const Text(
                'Keeping Flutter up-to-date is a good idea since it helps with many things including performance improvements, bug fixes and new features.',
                textAlign: TextAlign.center,
              ),
              VSeparators.normal(),
              infoWidget(context,
                  'You can still use Flutter in your IDE while we update. You will be asked to restart any opened editors once the update is complete. You can\'t use FlutterMatic while we update.'),
              VSeparators.small(),
              if (flutterActionState.loading)
                LoadActivityMessageElement(
                    message: flutterActionState.currentActivity)
              else
                RectangleButton(
                  loading: flutterActionState.loading,
                  width: double.infinity,
                  onPressed: () async {
                    await flutterActionNotifier.upgradeFlutterVersion();

                    if (!flutterActionState.loading &&
                        flutterActionState.error.isEmpty) {
                      if (mounted) {
                        Navigator.of(context).pop();
                      }

                      return;
                    }

                    if (mounted) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
                          context,
                          'Something went wrong while trying to upgrade Flutter. Please try again later.',
                          type: SnackBarType.error));
                    }
                  },
                  child: const Text('Check and Update Flutter'),
                ),
            ],
          ),
        );
      },
    );
  }
}
