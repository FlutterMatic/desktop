// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/views/dialogs/documentation.dart';
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';
import 'package:fluttermatic/meta/views/workflows/runner/elements/log_view_builder.dart';
import 'package:fluttermatic/meta/views/workflows/runner/logs.dart';
import 'package:fluttermatic/meta/views/workflows/runner/models/write_log.dart';
import 'package:fluttermatic/meta/views/workflows/runner/runner.dart';

class WorkflowError extends StatelessWidget {
  final File logFile;
  final WorkflowTemplate workflow;

  const WorkflowError({
    Key? key,
    required this.workflow,
    required this.logFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RoundContainer(
          height: 230,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('.... Click on "Logs" to view entire log'),
              Expanded(
                child: LogViewBuilder(
                  logs: logFile
                      .readAsLinesSync()
                      .sublist(logFile.readAsLinesSync().length - 6),
                ),
              ),
            ],
          ),
        ),
        VSeparators.normal(),
        informationWidget(
          'The workflow failed to complete because of some error. Check the logs to see what went wrong.',
          type: InformationType.error,
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
                child: const Text('Logs'),
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) =>
                        ViewWorkflowSessionLogs(logPath: logFile.path),
                  );
                },
              ),
              HSeparators.small(),
              RectangleButton(
                width: 100,
                child: const Text('Re-run'),
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => WorkflowRunnerDialog(workflow: workflow),
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
