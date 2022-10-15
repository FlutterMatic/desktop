// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/inputs/text_field.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/core/notifiers/models/state/actions/workflows.dart';
import 'package:fluttermatic/core/notifiers/notifiers/actions/workflows.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/general/app_theme.dart';
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';

class ConfirmWorkflowDelete extends StatefulWidget {
  final WorkflowTemplate workflow;

  const ConfirmWorkflowDelete({
    Key? key,
    required this.workflow,
  }) : super(key: key);

  @override
  _ConfirmWorkflowDeleteState createState() => _ConfirmWorkflowDeleteState();
}

class _ConfirmWorkflowDeleteState extends State<ConfirmWorkflowDelete> {
  String _confirmValue = '';

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        WorkflowsState workflowsState = ref.watch(workflowsActionStateNotifier);
        WorkflowsNotifier workflowsNotifier =
            ref.watch(workflowsActionStateNotifier.notifier);

        return WillPopScope(
          onWillPop: () async => !workflowsState.loading,
          child: DialogTemplate(
            outerTapExit: !workflowsState.loading,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DialogHeader(
                    title: 'Delete Workflow',
                    canClose: !workflowsState.loading),
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
                            Text(widget.workflow.name),
                            VSeparators.xSmall(),
                            Text(
                              widget.workflow.description,
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
                          if (!workflowsState.loading && mounted) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                    HSeparators.normal(),
                    Expanded(
                      child: RectangleButton(
                        loading: workflowsState.loading,
                        hoverColor: AppTheme.errorColor,
                        onPressed: () async {
                          try {
                            if (workflowsState.loading) {
                              return;
                            }

                            if (_confirmValue == 'DELETE') {
                              await workflowsNotifier
                                  .deleteWorkflow(widget.workflow);

                              if (mounted && !workflowsState.error) {
                                Navigator.pop(context);
                                return;
                              }

                              if (mounted && workflowsState.error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  snackBarTile(
                                    context,
                                    'Failed to delete workflow. Please try again.',
                                    type: SnackBarType.error,
                                  ),
                                );
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
                          } catch (e, s) {
                            await logger.file(
                                LogTypeTag.error, 'Failed to delete workflow',
                                stackTrace: s);

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
      },
    );
  }
}
