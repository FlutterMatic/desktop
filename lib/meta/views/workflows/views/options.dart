// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/meta/utils/general/app_theme.dart';
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';
import 'package:fluttermatic/meta/views/workflows/runner/runner.dart';
import 'package:fluttermatic/meta/views/workflows/startup.dart';
import 'package:fluttermatic/meta/views/workflows/views/delete.dart';
import 'package:fluttermatic/meta/views/workflows/views/logs.dart';
import 'package:fluttermatic/meta/views/workflows/views/preview.dart';

class ShowWorkflowTileOptions extends StatelessWidget {
  final WorkflowTemplate workflow;

  const ShowWorkflowTileOptions({
    Key? key,
    required this.workflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          const DialogHeader(title: 'Options'),
          Row(
            children: <Widget>[
              Expanded(
                child: RectangleButton(
                  height: 100,
                  child: Column(
                    children: <Widget>[
                      const Expanded(
                        child: Center(
                            child: Icon(Icons.preview_rounded, size: 25)),
                      ),
                      VSeparators.small(),
                      const Text('Preview'),
                    ],
                  ),
                  onPressed: () async {
                    Navigator.pop(context);

                    await showDialog(
                      context: context,
                      builder: (_) => PreviewWorkflowDialog(
                        workflow: workflow,
                      ),
                    );
                  },
                ),
              ),
              HSeparators.normal(),
              Expanded(
                child: RectangleButton(
                  height: 100,
                  child: Column(
                    children: <Widget>[
                      const Expanded(
                        child:
                            Center(child: Icon(Icons.edit_rounded, size: 25)),
                      ),
                      VSeparators.small(),
                      const Text('Edit'),
                    ],
                  ),
                  onPressed: () async {
                    Navigator.pop(context);

                    await showDialog(
                      context: context,
                      builder: (_) => StartUpWorkflow(
                        workflow: workflow,
                      ),
                    );
                  },
                ),
              ),
              HSeparators.normal(),
              Expanded(
                child: RectangleButton(
                  height: 100,
                  child: Column(
                    children: <Widget>[
                      const Expanded(child: Icon(Icons.history, size: 25)),
                      VSeparators.small(),
                      const Text('View Logs'),
                    ],
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (_) =>
                          ShowWorkflowLogHistory(workflow: workflow),
                    );
                  },
                ),
              ),
            ],
          ),
          VSeparators.normal(),
          Row(
            children: <Widget>[
              Expanded(
                child: Tooltip(
                  padding: const EdgeInsets.all(5),
                  message: !workflow.isSaved
                      ? '''
This workflow is not saved yet. You can edit it, 
but you will need to save it before you can run it.'''
                      : '',
                  child: RectangleButton(
                    height: 100,
                    disable: !workflow.isSaved,
                    child: Column(
                      children: <Widget>[
                        const Expanded(
                          child: Icon(Icons.play_arrow_rounded,
                              color: kGreenColor, size: 28),
                        ),
                        VSeparators.small(),
                        const Text('Run'),
                      ],
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (_) =>
                            WorkflowRunnerDialog(workflow: workflow),
                      );
                    },
                  ),
                ),
              ),
              HSeparators.normal(),
              Expanded(
                child: RectangleButton(
                  height: 100,
                  child: Column(
                    children: <Widget>[
                      const Expanded(
                        child: Icon(Icons.delete_forever,
                            color: AppTheme.errorColor, size: 28),
                      ),
                      VSeparators.small(),
                      const Text('Delete'),
                    ],
                  ),
                  onPressed: () async {
                    Navigator.pop(context);

                    await showDialog(
                      context: context,
                      builder: (_) => ConfirmWorkflowDelete(
                        workflow: workflow,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
