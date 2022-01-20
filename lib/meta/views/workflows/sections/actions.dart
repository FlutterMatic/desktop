// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/components/widgets/ui/warning_widget.dart';
import 'package:fluttermatic/core/libraries/constants.dart';
import 'package:fluttermatic/core/libraries/utils.dart';
import 'package:fluttermatic/meta/utils/extract_pubspec.dart';
import 'package:fluttermatic/meta/views/workflows/actions.dart';

class SetProjectWorkflowActions extends StatefulWidget {
  final String projectName;
  final String workflowName;
  final String workflowDescription;
  final PubspecInfo pubspecFile;
  final Function(List<WorkflowActionModel> actions) onActionsUpdate;
  final List<WorkflowActionModel> actions;
  final Function() onNext;

  const SetProjectWorkflowActions({
    Key? key,
    required this.projectName,
    required this.pubspecFile,
    required this.workflowName,
    required this.workflowDescription,
    required this.onActionsUpdate,
    required this.actions,
    required this.onNext,
  }) : super(key: key);

  @override
  _SetProjectWorkflowActionsState createState() =>
      _SetProjectWorkflowActionsState();
}

class _SetProjectWorkflowActionsState extends State<SetProjectWorkflowActions> {
  final List<WorkflowActionModel> _addedWorkflows = <WorkflowActionModel>[];

  @override
  void initState() {
    if (mounted) {
      setState(() => _addedWorkflows.addAll(widget.actions));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RoundContainer(
          width: double.infinity,
          color: Colors.blueGrey.withOpacity(0.2),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          widget.projectName.toUpperCase() +
                              ' - ' +
                              widget.workflowName,
                          style: const TextStyle(fontSize: 20),
                        ),
                        HSeparators.normal(),
                        SvgPicture.asset(Assets.done, height: 20),
                      ],
                    ),
                    VSeparators.small(),
                    Text(
                      widget.workflowDescription,
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              HSeparators.normal(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SvgPicture.asset(
                    widget.pubspecFile.isFlutterProject
                        ? Assets.flutter
                        : Assets.dart,
                    height: 25),
              ),
            ],
          ),
        ),
        if (_addedWorkflows.length == workflowActionModels.length)
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: informationWidget(
              'You decided to use all of the workflow actions. Good choice!',
              type: InformationType.green,
            ),
          ),
        VSeparators.normal(),
        infoWidget(context,
            'You can select more than one workflow to run. We will try to show you analysis and details about the result of these workflows when you run them. You will be able to change the order of this workflow in the next steps.'),
        VSeparators.normal(),
        DragTarget<WorkflowActionModel>(
          builder: (_, List<WorkflowActionModel?> candidateItems,
              List<dynamic> rejectedItems) {
            if (candidateItems.isNotEmpty && _addedWorkflows.isEmpty) {
              return const RoundContainer(
                borderColor: kGreenColor,
                borderWith: 2,
                child: Center(child: Text('Drop here')),
              );
            } else if (_addedWorkflows.isEmpty) {
              return RoundContainer(
                color: Colors.blueGrey.withOpacity(0.2),
                borderColor: kGreenColor.withOpacity(0.8),
                child: Row(
                  children: <Widget>[
                    SvgPicture.asset(Assets.warn, height: 20),
                    HSeparators.normal(),
                    const Expanded(
                      child: Text(
                          'Start by drag and dropping into this box at least one workflow action to use in this workflow.'),
                    ),
                  ],
                ),
              );
            } else {
              return RoundContainer(
                width: double.infinity,
                color: Colors.blueGrey.withOpacity(0.2),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <WorkflowActionModel?>[
                    ..._addedWorkflows,
                    ...candidateItems
                        .where((WorkflowActionModel? e) => e != null)
                        .toList(),
                  ].map(
                    (WorkflowActionModel? e) {
                      return RoundContainer(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(e?.name ?? 'err'),
                            HSeparators.xSmall(),
                            SquareButton(
                              icon: const Icon(Icons.close, size: 10),
                              size: 20,
                              color: Colors.blueGrey.withOpacity(0.2),
                              onPressed: () {
                                setState(() => _addedWorkflows.remove(e));
                                widget.onActionsUpdate(_addedWorkflows);
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  snackBarTile(
                                    context,
                                    '${e?.name ?? '"err"'} workflow action has been removed.',
                                    type: SnackBarType.warning,
                                    action: snackBarAction(
                                      text: 'Undo',
                                      onPressed: () => setState(
                                          () => _addedWorkflows.add(e!)),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ).toList(),
                ),
              );
            }
          },
          onWillAccept: (WorkflowActionModel? data) {
            if (_addedWorkflows.contains(data)) {
              return false;
            }
            return true;
          },
          onAccept: (WorkflowActionModel val) {
            setState(() => _addedWorkflows.add(val));
            widget.onActionsUpdate(_addedWorkflows);

            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              snackBarTile(
                context,
                '${val.name} workflow action has been added.',
                type: SnackBarType.done,
              ),
            );
          },
        ),
        if (_addedWorkflows.length != workflowActionModels.length)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: workflowActionModels.map((WorkflowActionModel e) {
                if (_addedWorkflows.contains(e)) {
                  return const SizedBox.shrink();
                }

                // Workflow action only for Dart.
                if (widget.pubspecFile.isFlutterProject &&
                    e.type == WorkflowActionForType.dart) {
                  return const SizedBox.shrink();
                }

                // Workflow action only for Flutter.
                if (!widget.pubspecFile.isFlutterProject &&
                    e.type == WorkflowActionForType.flutter) {
                  return const SizedBox.shrink();
                }

                return Draggable<WorkflowActionModel>(
                  data: e,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _addedWorkflows.add(e));
                      widget.onActionsUpdate(_addedWorkflows);
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        snackBarTile(
                          context,
                          '${e.name} workflow action has been added.',
                          type: SnackBarType.done,
                        ),
                      );
                    },
                    child: RoundContainer(
                      borderColor: _addedWorkflows.contains(e)
                          ? kGreenColor
                          : AppTheme.darkBackgroundColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(e.name),
                          VSeparators.xSmall(),
                          Text(e.description,
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                  feedback: Material(
                    color: Colors.transparent,
                    child: RoundContainer(
                      borderColor: _addedWorkflows.contains(e)
                          ? AppTheme.errorColor
                          : Colors.transparent,
                      color: Colors.blueGrey,
                      child: Text(e.name),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        VSeparators.normal(),
        Align(
          alignment: Alignment.centerRight,
          child: RectangleButton(
            width: 100,
            child: const Text('Continue'),
            onPressed: widget.onNext,
          ),
        ),
      ],
    );
  }
}
