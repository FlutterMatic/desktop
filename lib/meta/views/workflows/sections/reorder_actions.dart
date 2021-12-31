// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/buttons/rectangle_button.dart';
import 'package:manager/components/widgets/ui/round_container.dart';
import 'package:manager/components/widgets/ui/warning_widget.dart';
import 'package:manager/meta/views/workflows/actions.dart';

class SetProjectWorkflowActionsOrder extends StatefulWidget {
  final String workflowName;
  final List<WorkflowActionModel> workflowActions;
  final Function(List<WorkflowActionModel> list) onReorder;
  final Function() onNext;

  const SetProjectWorkflowActionsOrder({
    Key? key,
    required this.workflowName,
    required this.workflowActions,
    required this.onReorder,
    required this.onNext,
  }) : super(key: key);

  @override
  _SetProjectWorkflowActionsOrderState createState() =>
      _SetProjectWorkflowActionsOrderState();
}

class _SetProjectWorkflowActionsOrderState
    extends State<SetProjectWorkflowActionsOrder> {
  List<WorkflowActionModel> _workflowActions = <WorkflowActionModel>[];

  @override
  void initState() {
    if (mounted) {
      setState(() => _workflowActions = widget.workflowActions);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (widget.workflowActions.length == 1)
          informationWidget(
            'You can\'t actually reorder your workflow action since you only have one. You can go to the next step.',
            type: InformationType.info,
          )
        else
          informationWidget(
            'You can order your workflow actions to set the order they are executed in your ${widget.workflowName} workflow.',
            type: InformationType.green,
          ),
        VSeparators.normal(),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 350),
          child: ReorderableListView.builder(
            shrinkWrap: true,
            itemCount: _workflowActions.length,
            itemBuilder: (_, int i) {
              return RoundContainer(
                radius: 0,
                width: double.infinity,
                key: ValueKey<String>(_workflowActions[i].id),
                child: Row(
                  children: <Widget>[
                    Text(
                      (i + 1).toString() + ' - ',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    HSeparators.small(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(_workflowActions[i].name),
                        VSeparators.xSmall(),
                        Text(
                          _workflowActions[i].description,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            onReorder: (int oldIndex, int newIndex) {
              // Reorder the list with the new index. Then after it will call on
              // update to update.
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                WorkflowActionModel item = _workflowActions.removeAt(oldIndex);
                _workflowActions.insert(newIndex, item);
              });

              widget.onReorder(_workflowActions);
            },
          ),
        ),
        VSeparators.normal(),
        Align(
          alignment: Alignment.centerRight,
          child: RectangleButton(
            width: 100,
            child: const Text('Next'),
            onPressed: widget.onNext,
          ),
        ),
      ],
    );
  }
}
