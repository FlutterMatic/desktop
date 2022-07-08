// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/inputs/check_box_element.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/components/widgets/ui/load_activity_msg.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
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
          child: Column(
            children: <Widget>[
              const DialogHeader(
                title: 'Flutter Doctor',
                leading: StageTile(),
              ),
              if (!flutterActionState.isLoading &&
                  flutterActionState.flutterDoctor.isNotEmpty) ...<Widget>[
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 500),
                  child: SingleChildScrollView(
                    child: RoundContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            flutterActionState.flutterDoctor.map((String e) {
                          if (e.startsWith('Doctor summary')) {
                            return const SizedBox.shrink();
                          }

                          e = e.replaceAll('[âˆš]', '✅');
                          e = e.replaceAll('â€¢', '🟢');
                          e = e.replaceAll('[â˜ ]', '🔴');
                          e = e.replaceAll('X', '❌');

                          bool isLast =
                              flutterActionState.flutterDoctor.last == e;

                          return Padding(
                            padding: EdgeInsets.all(isLast ? 0 : 4),
                            child: SelectableText(e),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                )
              ] else ...<Widget>[
                infoWidget(context,
                    'We will now run a diagnostic test for Flutter on your device to make sure everything is working as expected.'),
                VSeparators.normal(),
                CheckBoxElement(
                  disable: flutterActionState.isLoading,
                  onChanged: (bool? val) =>
                      setState(() => _verbose = val ?? false),
                  value: _verbose,
                  text: 'Verbose output (details about issues found)',
                ),
                VSeparators.normal(),
                if (flutterActionState.isLoading)
                  LoadActivityMessageElement(
                    message: flutterActionState.flutterDoctor.isEmpty
                        ? ''
                        : flutterActionState.flutterDoctor.last,
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
