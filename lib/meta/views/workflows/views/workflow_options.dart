// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/coming_soon.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/spinner.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';
import 'package:fluttermatic/meta/views/workflows/runner/runner.dart';
import 'package:fluttermatic/meta/views/workflows/startup.dart';
import 'package:fluttermatic/meta/views/workflows/views/confirm_delete.dart';
import 'package:fluttermatic/meta/views/workflows/views/log_history.dart';

class ShowWorkflowTileOptions extends StatefulWidget {
  final String workflowPath;
  final Function() onDelete;

  const ShowWorkflowTileOptions({
    Key? key,
    required this.workflowPath,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<ShowWorkflowTileOptions> createState() =>
      _ShowWorkflowTileOptionsState();
}

class _ShowWorkflowTileOptionsState extends State<ShowWorkflowTileOptions> {
  bool _loading = true;

  Future<void> _loadWorkflow() async {
    if (!await File(widget.workflowPath).exists()) {
      widget.onDelete();
      await Future<void>.delayed(const Duration(milliseconds: 300));
      Navigator.pop(context);
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    _loadWorkflow();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          const DialogHeader(title: 'Options'),
          if (_loading) ...<Widget>[
            const Padding(padding: EdgeInsets.all(30), child: Spinner()),
          ] else ...<Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: RectangleButton(
                    height: 100,
                    child: Column(
                      children: <Widget>[
                        // const Expanded(
                        //     child: Icon(Icons.preview_rounded, size: 25)),
                        // VSeparators.small(),
                        const Expanded(child: Center(child: Text('Preview'))),
                        VSeparators.small(),
                        const ComingSoonTile(),
                      ],
                    ),
                    // TODO: Open preview
                    onPressed: () {},
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
                      Map<String, dynamic> _workflow = jsonDecode(
                          await File(widget.workflowPath).readAsString());

                      await showDialog(
                        context: context,
                        builder: (_) => StartUpWorkflow(
                          pubspecPath: (widget.workflowPath.split('\\')
                                    ..removeLast()
                                    ..removeLast())
                                  .join('\\') +
                              '\\pubspec.yaml',
                          editWorkflowTemplate:
                              WorkflowTemplate.fromJson(_workflow),
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
                        builder: (_) => ShowWorkflowLogHistory(
                            workflowPath: widget.workflowPath),
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
                    message: !WorkflowTemplate.fromJson(jsonDecode(
                                File(widget.workflowPath).readAsStringSync()))
                            .isSaved
                        ? 'This workflow is not saved yet. You can edit it, but you will need to save it before you can run it.'
                        : '',
                    child: RectangleButton(
                      height: 100,
                      disable: !WorkflowTemplate.fromJson(jsonDecode(
                              File(widget.workflowPath).readAsStringSync()))
                          .isSaved,
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
                          builder: (_) => WorkflowRunnerDialog(
                              workflowPath: widget.workflowPath),
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
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (_) => ConfirmWorkflowDelete(
                          path: widget.workflowPath,
                          template: WorkflowTemplate.fromJson(jsonDecode(
                              File(widget.workflowPath).readAsStringSync())),
                          onClose: (bool d) {
                            if (d) {
                              return widget.onDelete();
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
