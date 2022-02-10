import 'package:flutter/material.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/stage_tile.dart';
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';

class PreviewWorkflowDialog extends StatelessWidget {
  final WorkflowTemplate template;

  const PreviewWorkflowDialog({
    Key? key,
    required this.template,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          DialogHeader(
            title: 'Preview Workflow',
            leading: StageTile(stageType: StageType.prerelease),
          ),
        ],
      ),
    );
  }
}
