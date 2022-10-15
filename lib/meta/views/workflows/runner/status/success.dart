// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';
import 'package:fluttermatic/meta/views/workflows/runner/logs.dart';
import 'package:fluttermatic/meta/views/workflows/runner/models/write_log.dart';

class WorkflowSuccess extends StatelessWidget {
  final WorkflowTemplate workflow;
  final String elapsedTime;
  final File logFile;

  const WorkflowSuccess({
    Key? key,
    required this.elapsedTime,
    required this.workflow,
    required this.logFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        VSeparators.normal(),
        SvgPicture.asset(Assets.done, color: kGreenColor),
        VSeparators.normal(),
        SizedBox(
          width: 500,
          child: Text(
            'Your workflow has completed running. It took $elapsedTime to complete. If you need to check the logs of this workflow run session, you can click to open it.',
            textAlign: TextAlign.center,
          ),
        ),
        VSeparators.normal(),
        RoundContainer(
          width: 500,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(workflow.name),
                    VSeparators.xSmall(),
                    Text(workflow.description,
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              HSeparators.normal(),
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
              HSeparators.normal(),
              RectangleButton(
                width: 100,
                child: const Text('Close'),
                onPressed: () {
                  writeWorkflowSessionLog(
                      logFile, LogTypeTag.info, 'Workflow session ended.');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
