// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/inputs/check_box_element.dart';
import 'package:fluttermatic/components/widgets/ui/beta_tile.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/components/widgets/ui/load_activity_msg.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/core/services/logs.dart';

class FlutterDoctorDialog extends StatefulWidget {
  const FlutterDoctorDialog({Key? key}) : super(key: key);

  @override
  _FlutterDoctorDialogState createState() => _FlutterDoctorDialogState();
}

class _FlutterDoctorDialogState extends State<FlutterDoctorDialog> {
  bool _done = false;
  bool _running = false;

  // Inputs
  bool _verbose = false;
  final List<String> _status = <String>[];

  Future<void> _runDoctor() async {
    try {
      setState(() => _running = true);

      await shell
          .run('flutter doctor' + (_verbose ? ' -v' : ''))
          .asStream()
          .listen((List<ProcessResult> line) {
        if (mounted) {
          setState(() {
            _status.addAll(line.last.stdout.toString().split('\n'));

            // Remove all the empty lines
            _status.removeWhere((String e) => e.isEmpty);
            _status.removeWhere((String e) {
              return e.contains('issue found!');
            });
          });
        }
      }).asFuture();

      print(_status);

      await logger.file(LogTypeTag.info,
          'Flutter doctor run ${_verbose ? 'with verbose' : 'without verbose'}: ${_status.join('\n')}');

      setState(() {
        _done = true;
        _running = false;
      });
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Flutter Doctor failed to run: $_',
          stackTraces: s);

      setState(() {
        _running = false;
        _status.clear();
        _done = false;
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
        context,
        'Failed to run Flutter doctor. Please try again.',
        type: SnackBarType.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_running,
      child: DialogTemplate(
        outerTapExit: false,
        child: Column(
          children: <Widget>[
            DialogHeader(
              title: 'Flutter Doctor',
              leading: const StageTile(),
              canClose: !_running,
            ),
            if (_done) ...<Widget>[
              RoundContainer(
                color: Colors.blueGrey.withOpacity(0.2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _status.map((String e) {
                    if (e.startsWith('Doctor summary')) {
                      return const SizedBox.shrink();
                    }

                    e = e.replaceAll('[âˆš]', '✅');
                    e = e.replaceAll('â€¢', '🟢');

                    bool _isLast = _status.last == e;

                    return Padding(
                      padding: EdgeInsets.all(_isLast ? 0 : 4),
                      child: SelectableText(e),
                    );
                  }).toList(),
                ),
              )
            ] else ...<Widget>[
              infoWidget(context,
                  'We will now run a Flutter diagnostic test for Flutter on your device to see everything is working as expected.'),
              VSeparators.normal(),
              CheckBoxElement(
                onChanged: (bool? val) {
                  setState(() => _verbose = val ?? false);
                },
                value: _verbose,
                text: 'Verbose output (details about issues found)',
              ),
              VSeparators.normal(),
              if (_running)
                LoadActivityMessageElement(
                    message: _status.isEmpty ? '' : _status.last)
              else
                RectangleButton(
                  width: double.infinity,
                  child: const Text('Start'),
                  onPressed: _runDoctor,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
