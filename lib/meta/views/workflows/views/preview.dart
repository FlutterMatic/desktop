// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/stage_tile.dart';
import 'package:fluttermatic/meta/views/workflows/actions.dart';
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';
import 'package:fluttermatic/meta/views/workflows/startup.dart';

class PreviewWorkflowDialog extends StatelessWidget {
  final WorkflowTemplate workflow;

  const PreviewWorkflowDialog({
    Key? key,
    required this.workflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      width: 800,
      child: Column(
        children: <Widget>[
          const DialogHeader(
            title: 'Preview Workflow',
            leading: StageTile(stageType: StageType.beta),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    itemCount: workflow.workflowActions.length,
                    itemBuilder: (_, int i) {
                      bool isLast = i == workflow.workflowActions.length - 1;

                      WorkflowActionModel actionModel =
                          workflowActionModels.firstWhere(
                              (_) => _.id == workflow.workflowActions[i]);

                      int? getTimeout() {
                        switch (actionModel.id) {
                          case WorkflowActionsIds.buildProjectForAndroid:
                            return workflow.androidBuildTimeout;
                          case WorkflowActionsIds.buildProjectForIOS:
                            return workflow.iOSBuildTimeout;
                          case WorkflowActionsIds.buildProjectForWeb:
                            return workflow.webBuildTimeout;
                          case WorkflowActionsIds.buildProjectForWindows:
                            return workflow.windowsBuildTimeout;
                          case WorkflowActionsIds.buildProjectForMacOS:
                            return workflow.macosBuildTimeout;
                          case WorkflowActionsIds.buildProjectForLinux:
                            return workflow.linuxBuildTimeout;
                          default:
                            return null;
                        }
                      }

                      return Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                        child: Builder(
                          builder: (_) {
                            if (actionModel.id ==
                                WorkflowActionsIds.runCustomCommands) {
                              return RoundContainer(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    _stepItem(
                                      i,
                                      title: actionModel.name,
                                      description: actionModel.description,
                                      timeout: getTimeout(),
                                    ),
                                    VSeparators.normal(),
                                    ...workflow.customCommands.map((_) {
                                      return Text(
                                        '   - $_',
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      );
                                    }),
                                  ],
                                ),
                              );
                            }

                            return _stepItem(
                              i,
                              title: actionModel.name,
                              description: actionModel.description,
                              timeout: getTimeout(),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                HSeparators.normal(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (<int>[
                        workflow.iOSBuildTimeout,
                        workflow.androidBuildTimeout,
                        workflow.webBuildTimeout,
                        workflow.windowsBuildTimeout,
                        workflow.macosBuildTimeout,
                        workflow.linuxBuildTimeout,
                      ].any((_) => _ != 0)) ...<Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: informationWidget(
                              'Some build actions have a timeout set.',
                              type: InformationType.info),
                        ),
                      ],
                      Expanded(
                        child: Text('''
You have a total of ${workflow.workflowActions.length} action${workflow.workflowActions.length == 1 ? '' : 's'} that will be executed in order. 

If any of them takes longer than the timeout set, the workflow will be stopped. 

Also, if any fail with a none-zero exit code, the workflow will be stopped automatically.'''),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SquareButton(
                          tooltip: 'Edit Workflow',
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () async {
                            Navigator.pop(context);

                            await showDialog(
                              context: context,
                              builder: (_) => StartUpWorkflow(
                                pubspecPath:
                                    '${(workflow.workflowPath.split('\\')
                                      ..removeLast()
                                      ..removeLast()).join('\\')}\\pubspec.yaml',
                                workflow: workflow,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _stepItem(
  int index, {
  required String title,
  required String description,
  required int? timeout,
}) {
  return RoundContainer(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(title),
            if (timeout != null && timeout != 0)
              Text(
                ' ($timeout minutes timeout)',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            const Spacer(),
            Text('${index + 1}'),
          ],
        ),
        VSeparators.xSmall(),
        Text(
          description,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    ),
  );
}
