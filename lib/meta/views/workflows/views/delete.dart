// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/inputs/text_field.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/general/app_theme.dart';
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';

class ConfirmWorkflowDelete extends StatefulWidget {
  final String path;
  final WorkflowTemplate template;
  final Function(bool hasDeleted) onClose;

  const ConfirmWorkflowDelete({
    Key? key,
    required this.path,
    required this.onClose,
    required this.template,
  }) : super(key: key);

  @override
  _ConfirmWorkflowDeleteState createState() => _ConfirmWorkflowDeleteState();
}

class _ConfirmWorkflowDeleteState extends State<ConfirmWorkflowDelete> {
  bool _loading = false;
  String _confirmValue = '';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_loading,
      child: DialogTemplate(
        outerTapExit: !_loading,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DialogHeader(title: 'Delete Workflow', canClose: !_loading),
            informationWidget(
              'Are you sure you want to delete this workflow? This action cannot be undone.',
              type: InformationType.warning,
            ),
            VSeparators.normal(),
            RoundContainer(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(widget.template.name),
                        VSeparators.xSmall(),
                        Text(
                          widget.template.description,
                          style: const TextStyle(color: Colors.grey),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  HSeparators.normal(),
                  const Icon(Icons.play_circle_outline_rounded,
                      color: kGreenColor, size: 20),
                ],
              ),
            ),
            VSeparators.normal(),
            const Text(
                'To confirm delete, please type "DELETE", case-sensitive.'),
            VSeparators.normal(),
            CustomTextField(
              hintText: 'Confirm Delete',
              onChanged: (String e) => setState(() => _confirmValue = e),
            ),
            VSeparators.normal(),
            Row(
              children: <Widget>[
                Expanded(
                  child: RectangleButton(
                    child: const Text('Cancel'),
                    onPressed: () async {
                      if (!_loading) {
                        await widget.onClose(false);

                        if (mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                  ),
                ),
                HSeparators.normal(),
                Expanded(
                  child: RectangleButton(
                    loading: _loading,
                    hoverColor: AppTheme.errorColor,
                    onPressed: () async {
                      try {
                        if (_loading) {
                          return;
                        }
                        setState(() => _loading = true);

                        if (_confirmValue == 'DELETE') {
                          await File(widget.path).delete();

                          // Check to see if this workflow has any logs and
                          // delete them as well.
                          Directory logsDir = Directory(
                              '${(widget.path.split('\\')..removeLast()).join('\\')}\\logs\\${widget.path.split('\\').last.split('.').first}');

                          if (await logsDir.exists()) {
                            await logsDir.delete(recursive: true);
                            await logger.file(LogTypeTag.info,
                                'Deleted logs for workflow ${widget.path.split('\\').last}');
                          }

                          Iterable<FileSystemEntity> existingWorkflows =
                              Directory((widget.path.split('\\')..removeLast())
                                      .join('\\'))
                                  .listSync()
                                  .whereType<File>();

                          // If there are no more workflows, then delete the
                          // entire workflows directory.
                          if (existingWorkflows.isEmpty) {
                            await Directory((widget.path.split('\\')
                                      ..removeLast())
                                    .join('\\'))
                                .delete(recursive: true);
                            await logger.file(LogTypeTag.info,
                                'Deleted project "$fmWorkflowDir" directory because no more workflows exist in it.');
                          }

                          await logger.file(LogTypeTag.info,
                              'Deleted a workflow file from ${widget.path}');
                          await widget.onClose(true);

                          if (mounted) {
                            Navigator.pop(context);
                          }
                        } else {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context)
                              .showSnackBar(snackBarTile(
                            context,
                            'Please confirm by typing "DELETE". Input is case-sensitive.',
                            type: SnackBarType.error,
                          ));
                        }
                      } catch (_, s) {
                        await logger.file(
                            LogTypeTag.error, 'Failed to delete workflow',
                            stackTraces: s);
                        widget.onClose(false);

                        if (mounted) {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            snackBarTile(
                              context,
                              'Failed to delete workflow. Please try again.',
                              type: SnackBarType.error,
                            ),
                          );
                        }
                      }
                      setState(() => _loading = false);
                    },
                    child: const Text('Delete'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
