// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/meta/views/workflows/runner/elements/log_view_builder.dart';

class ViewWorkflowSessionLogs extends StatefulWidget {
  final String logPath;

  const ViewWorkflowSessionLogs({Key? key, required this.logPath})
      : super(key: key);

  @override
  _ViewWorkflowSessionLogsState createState() =>
      _ViewWorkflowSessionLogsState();
}

class _ViewWorkflowSessionLogsState extends State<ViewWorkflowSessionLogs> {
  final List<String> _logs = <String>[];

  Future<void> _init() async {
    File logFile = File(widget.logPath);

    if (!await logFile.exists()) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        snackBarTile(context, 'This log file no longer exists.',
            type: SnackBarType.error),
      );

      Navigator.pop(context);
      return;
    }

    List<String> logs = await logFile.readAsLines();

    while (logs.isNotEmpty && logs.first.isEmpty) {
      logs.removeAt(0);
    }

    while (logs.isNotEmpty && logs.last.isEmpty) {
      logs.removeLast();
    }

    setState(() => _logs.addAll(logs));
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          const DialogHeader(title: 'Workflow Session Logs'),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: LogViewBuilder(logs: _logs),
          ),
          VSeparators.normal(),
          RectangleButton(
            width: double.infinity,
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
