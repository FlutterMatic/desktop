// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/views/dialogs/documentation.dart';
import 'package:fluttermatic/meta/views/workflows/runner/elements/log_view_builder.dart';
import 'package:fluttermatic/meta/views/workflows/runner/models/write_log.dart';
import 'package:fluttermatic/meta/views/workflows/runner/runner.dart';

class WorkflowStopped extends StatelessWidget {
  final String path;
  final File logFile;

  const WorkflowStopped({
    Key? key,
    required this.path,
    required this.logFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> _logFile = File(logFile.path).readAsLinesSync();
    return Column(
      children: <Widget>[
        RoundContainer(
          height: 230,
          child: LogViewBuilder(
            logs: _logFile
                .sublist((_logFile.length - 6) > 0 ? _logFile.length - 6 : 0),
          ),
        ),
        VSeparators.normal(),
        infoWidget(context,
            'Note that the last running workflow action may continue to run in the background until it finishes.'),
        VSeparators.normal(),
        informationWidget(
          'You force stopped this workflow. You can restart it by clicking the button below.',
        ),
        VSeparators.normal(),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RectangleButton(
                width: 100,
                child: const Text('Close'),
                onPressed: () {
                  writeWorkflowSessionLog(
                      logFile, LogTypeTag.info, 'Workflow session ended.');
                  Navigator.of(context).pop();
                },
              ),
              HSeparators.small(),
              RectangleButton(
                width: 100,
                child: const Text('Restart'),
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => WorkflowRunnerDialog(workflowPath: path),
                  );
                },
              ),
              HSeparators.small(),
              RectangleButton(
                width: 100,
                child: const Text('View Docs'),
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => const DocumentationDialog(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
