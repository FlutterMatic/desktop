// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';
import 'package:fluttermatic/meta/views/workflows/actions.dart';
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';
import 'package:fluttermatic/meta/views/workflows/runner/runner.dart';
import 'package:fluttermatic/meta/views/workflows/startup.dart';
import 'package:fluttermatic/meta/views/workflows/views/delete.dart';
import 'package:fluttermatic/meta/views/workflows/views/options.dart';

class WorkflowInfoTile extends StatefulWidget {
  final String path;
  final Function() onDelete;
  final WorkflowTemplate workflow;
  final Function() onReload;

  const WorkflowInfoTile({
    Key? key,
    required this.workflow,
    required this.path,
    required this.onDelete,
    required this.onReload,
  }) : super(key: key);

  @override
  _WorkflowInfoTileState createState() => _WorkflowInfoTileState();
}

class _WorkflowInfoTileState extends State<WorkflowInfoTile> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: RoundContainer(
        height: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          widget.workflow.name,
                          style: const TextStyle(fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                      if (_isHovering)
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: RectangleButton(
                            padding: EdgeInsets.zero,
                            child: const Icon(Icons.more_vert, size: 14),
                            color: Colors.transparent,
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (_) => ShowWorkflowTileOptions(
                                  onDelete: widget.onDelete,
                                  workflowPath: widget.path,
                                  onReload: widget.onReload,
                                ),
                              );
                            },
                            radius: BorderRadius.circular(2),
                            width: 22,
                            height: 22,
                          ),
                        ),
                    ],
                  ),
                  VSeparators.normal(),
                  Expanded(
                    child: Text(
                      widget.workflow.description,
                      style: const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                  ),
                  VSeparators.normal(),
                  Builder(
                    builder: (_) {
                      if (!_isHovering) {
                        return const SizedBox.shrink();
                      }

                      if (widget.workflow.workflowActions.isEmpty) {
                        return const RoundContainer(
                          width: double.infinity,
                          child: Text(
                              'No actions - yet. Edit workflow to add actions to run.'),
                        );
                      } else if (widget.workflow.workflowActions.length == 1) {
                        return Row(
                          children: <Widget>[
                            const RoundContainer(
                              height: 10,
                              width: 10,
                              radius: 10,
                              padding: EdgeInsets.zero,
                              color: kGreenColor,
                              child: SizedBox.shrink(),
                            ),
                            HSeparators.small(),
                            Text(
                              workflowActionModels
                                  .firstWhere((WorkflowActionModel element) {
                                return element.id ==
                                    widget.workflow.workflowActions.first;
                              }).name,
                              style: const TextStyle(color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        );
                      } else {
                        // Will show the first and last action if there are more
                        // than one
                        return Row(
                          children: <Widget>[
                            const RoundContainer(
                              height: 10,
                              width: 10,
                              radius: 10,
                              padding: EdgeInsets.zero,
                              color: kGreenColor,
                              child: SizedBox.shrink(),
                            ),
                            HSeparators.small(),
                            Text(
                              workflowActionModels
                                  .firstWhere((WorkflowActionModel element) {
                                return element.id ==
                                    widget.workflow.workflowActions.first;
                              }).name,
                              style: const TextStyle(color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            HSeparators.xSmall(),
                            if (widget.workflow.workflowActions.length == 2)
                              const Text('...',
                                  style: TextStyle(color: Colors.grey))
                            else
                              const RoundContainer(
                                height: 2,
                                width: 10,
                                color: kGreenColor,
                                child: SizedBox.shrink(),
                              ),
                            HSeparators.xSmall(),
                            Text(
                              workflowActionModels
                                  .firstWhere((WorkflowActionModel element) {
                                return element.id ==
                                    widget.workflow.workflowActions.last;
                              }).name,
                              style: const TextStyle(color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  VSeparators.small(),
                  if (widget.workflow.workflowActions.isNotEmpty)
                    Row(
                      children: <Widget>[
                        const Icon(Icons.play_circle_outline_rounded,
                            color: kGreenColor, size: 14),
                        HSeparators.xSmall(),
                        Text(
                          widget.workflow.workflowActions.length.toString() +
                              ' action${widget.workflow.workflowActions.length == 1 ? '' : 's'}',
                          style: const TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                      ],
                    ),
                ],
              ),
            ),
            VSeparators.normal(),
            Row(
              children: <Widget>[
                if (!widget.workflow.isSaved)
                  Tooltip(
                    padding: const EdgeInsets.all(5),
                    message: '''
This workflow has not completed setup yet - or, you will need to go through 
setup again because we added some new features that need to be migrated.''',
                    child: SvgPicture.asset(Assets.warn, height: 20),
                  ),
                const Spacer(),
                Tooltip(
                  message: 'Edit workflow',
                  waitDuration: const Duration(seconds: 1),
                  child: RectangleButton(
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.edit_rounded, size: 20),
                    onPressed: () async {
                      Map<String, dynamic> _workflow =
                          jsonDecode(await File(widget.path).readAsString());

                      await showDialog(
                        context: context,
                        builder: (_) => StartUpWorkflow(
                          pubspecPath: (widget.path.split('\\')
                                    ..removeLast()
                                    ..removeLast())
                                  .join('\\') +
                              '\\pubspec.yaml',
                          editWorkflowTemplate:
                              WorkflowTemplate.fromJson(_workflow),
                        ),
                      );

                      widget.onReload();
                    },
                  ),
                ),
                HSeparators.small(),
                if (widget.workflow.isSaved)
                  Tooltip(
                    message: 'Run workflow',
                    waitDuration: const Duration(seconds: 1),
                    child: RectangleButton(
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.play_arrow_rounded,
                          color: kGreenColor, size: 22),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) =>
                              WorkflowRunnerDialog(workflowPath: widget.path),
                        );
                      },
                    ),
                  )
                else
                  Tooltip(
                    message: 'Delete workflow',
                    waitDuration: const Duration(seconds: 1),
                    child: RectangleButton(
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.delete_forever_rounded,
                          color: AppTheme.errorColor, size: 20),
                      onPressed: () async {
                        WorkflowTemplate _template = WorkflowTemplate.fromJson(
                            jsonDecode(await File(widget.path).readAsString()));
                        await showDialog(
                          context: context,
                          builder: (_) => ConfirmWorkflowDelete(
                            onClose: (bool deleted) {
                              if (deleted) {
                                widget.onDelete();
                              }
                            },
                            path: widget.path,
                            template: _template,
                          ),
                        );
                      },
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
