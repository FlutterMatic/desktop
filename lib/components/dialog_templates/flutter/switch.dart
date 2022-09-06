// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/buttons/select_tiles.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/load_activity_msg.dart';
import 'package:fluttermatic/components/widgets/ui/shimmer.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/components/widgets/ui/stage_tile.dart';
import 'package:fluttermatic/core/notifiers/models/state/actions/flutter.dart';
import 'package:fluttermatic/core/notifiers/models/state/checks/flutter.dart';
import 'package:fluttermatic/core/notifiers/notifiers/actions/flutter.dart';
import 'package:fluttermatic/core/notifiers/out.dart';

class SwitchFlutterChannelDialog extends ConsumerStatefulWidget {
  const SwitchFlutterChannelDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChangeFlutterChannelDialogState();
}

class _ChangeFlutterChannelDialogState
    extends ConsumerState<SwitchFlutterChannelDialog> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        FlutterState flutterState = ref.watch(flutterNotifierController);

        String selectedChannel = flutterState.channel.toLowerCase();

        FlutterActionsState flutterActionsState =
            ref.watch(flutterActionsStateNotifier);

        FlutterActionsNotifier flutterActionsNotifier =
            ref.watch(flutterActionsStateNotifier.notifier);

        return DialogTemplate(
          child: Shimmer.fromColors(
            enabled: flutterActionsState.isLoading,
            child: IgnorePointer(
              ignoring: flutterActionsState.isLoading,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const DialogHeader(
                    title: 'Change Channel',
                    leading: StageTile(),
                  ),
                  const Text(
                    'Choose a new channel to switch to. Switching to a new channel may take a while. New resources will be installed on your device. We recommend staying on the stable channel.',
                    style: TextStyle(fontSize: 13),
                  ),
                  VSeparators.normal(),
                  SelectTile(
                    onPressed: (val) => setState(() => selectedChannel = val),
                    defaultValue: selectedChannel,
                    options: const <String>['Master', 'Stable', 'Beta', 'Dev'],
                  ),
                  VSeparators.small(),
                  AnimatedOpacity(
                    opacity: flutterActionsState.isLoading ? 0.1 : 1,
                    duration: const Duration(milliseconds: 300),
                    child: informationWidget(
                      'We recommend staying on the stable channel for best development experience unless it\'s necessary.',
                      type: InformationType.warning,
                    ),
                  ),
                  VSeparators.small(),
                  if (flutterActionsState.isLoading) ...[
                    LoadActivityMessageElement(
                      message: flutterActionsState.currentProcess,
                    ),
                    VSeparators.normal(),
                    informationWidget(
                        'You can close this dialog while we switch your Flutter channels. We will notify you once we are done.'),
                  ] else
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: RectangleButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        HSeparators.normal(),
                        Expanded(
                          child: RectangleButton(
                            child: const Text('Continue'),
                            onPressed: () async {
                              if (flutterState.channel.toLowerCase() ==
                                  selectedChannel.toLowerCase()) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                    snackBarTile(context,
                                        'You are already on ${flutterState.channel} channel. Select a different channel to continue.'));
                                return;
                              } else {
                                await flutterActionsNotifier
                                    .switchDifferentChannel(selectedChannel);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
