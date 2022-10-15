// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/inputs/check_box_element.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/components/widgets/ui/load_activity_msg.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/components/widgets/ui/stage_tile.dart';
import 'package:fluttermatic/core/notifiers/models/state/actions/flutter.dart';
import 'package:fluttermatic/core/notifiers/notifiers/actions/flutter.dart';
import 'package:fluttermatic/core/notifiers/out.dart';

class FlutterDoctorDialog extends StatefulWidget {
  const FlutterDoctorDialog({Key? key}) : super(key: key);

  @override
  _FlutterDoctorDialogState createState() => _FlutterDoctorDialogState();
}

class _FlutterDoctorDialogState extends State<FlutterDoctorDialog> {
  // Inputs
  bool _verbose = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        FlutterActionsState flutterActionState =
            ref.watch(flutterActionsStateNotifier);

        FlutterActionsNotifier flutterActionNotifier =
            ref.watch(flutterActionsStateNotifier.notifier);

        return DialogTemplate(
          width: flutterActionNotifier.flutterDoctor.isNotEmpty ? 700 : null,
          child: Column(
            children: <Widget>[
              const DialogHeader(
                title: 'Flutter Doctor',
                leading: StageTile(),
              ),
              if (!flutterActionState.loading &&
                  flutterActionNotifier.flutterDoctor.isNotEmpty) ...<Widget>[
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 500),
                  child: SingleChildScrollView(
                    child: RoundContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            flutterActionNotifier.flutterDoctor.map((String e) {
                          if (e.startsWith('Doctor summary')) {
                            return const SizedBox.shrink();
                          }

                          bool isLast =
                              flutterActionNotifier.flutterDoctor.last == e;

                          return Padding(
                            padding: EdgeInsets.all(isLast ? 0 : 4),
                            child: SelectableText(e),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                VSeparators.normal(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    SquareButton(
                      tooltip: 'Copy to clipboard',
                      icon: const Icon(Icons.copy_rounded),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                            text: flutterActionNotifier.flutterDoctor
                                .join('\n')));

                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          snackBarTile(
                            context,
                            'Flutter Doctor Result has been copied.',
                            type: SnackBarType.done,
                          ),
                        );
                      },
                    ),
                    HSeparators.normal(),
                    Expanded(
                      child: RectangleButton(
                        onPressed: () {
                          flutterActionNotifier.resetFlutterDoctor();
                          setState(() {});
                        },
                        child: const Text('Restart'),
                      ),
                    ),
                  ],
                ),
              ] else ...<Widget>[
                infoWidget(context,
                    'We will now run a diagnostic test for Flutter on your device to make sure everything is working as expected.'),
                VSeparators.normal(),
                CheckBoxElement(
                  disable: flutterActionState.loading,
                  onChanged: (bool? val) =>
                      setState(() => _verbose = val ?? false),
                  value: _verbose,
                  text: 'Verbose output (details about issues found)',
                ),
                VSeparators.normal(),
                if (flutterActionState.loading)
                  LoadActivityMessageElement(
                    message: flutterActionNotifier.flutterDoctor.isEmpty
                        ? ''
                        : flutterActionNotifier.flutterDoctor.last,
                  )
                else
                  RectangleButton(
                    width: double.infinity,
                    onPressed: () =>
                        flutterActionNotifier.runFlutterDoctor(_verbose),
                    child: const Text('Start'),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}
