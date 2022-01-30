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
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';
import 'package:fluttermatic/meta/views/workflows/runner/runner.dart';
import 'package:fluttermatic/meta/views/workflows/startup.dart';
import 'package:fluttermatic/meta/views/workflows/views/workflow_options.dart';

class WorkflowInfoTile extends StatefulWidget {
  final String path;
  final Function() onDelete;
  final WorkflowTemplate workflow;

  const WorkflowInfoTile({
    Key? key,
    required this.workflow,
    required this.path,
    required this.onDelete,
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
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => ShowWorkflowTileOptions(
                                  onDelete: widget.onDelete,
                                  workflowPath: widget.path,
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
                  Text(
                    widget.workflow.description,
                    style: const TextStyle(color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                  VSeparators.normal(),
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
                  VSeparators.normal(),
                ],
              ),
            ),
            HSeparators.normal(),
            Row(
              children: <Widget>[
                if (!widget.workflow.isSaved && _isHovering)
                  Tooltip(
                    message: 'This workflow has not completed setup yet',
                    child: SvgPicture.asset(Assets.warn, height: 20),
                  ),
                const Spacer(),
                RectangleButton(
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
                  },
                ),
                if (widget.workflow.isSaved)
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
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
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
