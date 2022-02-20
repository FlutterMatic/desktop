// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
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
  final String workflowPath;
  final WorkflowTemplate template;
  final Function() onReload;

  const PreviewWorkflowDialog({
    Key? key,
    required this.template,
    required this.workflowPath,
    required this.onReload,
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
                    itemCount: template.workflowActions.length,
                    itemBuilder: (_, int i) {
                      bool _isLast = i == template.workflowActions.length - 1;

                      WorkflowActionModel _actionModel =
                          workflowActionModels.firstWhere(
                              (_) => _.id == template.workflowActions[i]);

                      int? _getTimeout() {
                        switch (_actionModel.id) {
                          case WorkflowActionsIds.buildProjectForAndroid:
                            return template.androidBuildTimeout;
                          case WorkflowActionsIds.buildProjectForIOS:
                            return template.iOSBuildTimeout;
                          case WorkflowActionsIds.buildProjectForWeb:
                            return template.webBuildTimeout;
                          case WorkflowActionsIds.buildProjectForWindows:
                            return template.windowsBuildTimeout;
                          case WorkflowActionsIds.buildProjectForMacOS:
                            return template.macosBuildTimeout;
                          case WorkflowActionsIds.buildProjectForLinux:
                            return template.linuxBuildTimeout;
                          default:
                            return null;
                        }
                      }

                      return Padding(
                        padding: EdgeInsets.only(bottom: _isLast ? 0 : 10),
                        child: Builder(
                          builder: (_) {
                            if (_actionModel.id ==
                                WorkflowActionsIds.runCustomCommands) {
                              return RoundContainer(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    _stepItem(
                                      i,
                                      title: _actionModel.name,
                                      description: _actionModel.description,
                                      timeout: _getTimeout(),
                                    ),
                                    VSeparators.normal(),
                                    ...template.customCommands.map((_) {
                                      return Text(
                                        '   - ' + _,
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
                              title: _actionModel.name,
                              description: _actionModel.description,
                              timeout: _getTimeout(),
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
                        template.iOSBuildTimeout,
                        template.androidBuildTimeout,
                        template.webBuildTimeout,
                        template.windowsBuildTimeout,
                        template.macosBuildTimeout,
                        template.linuxBuildTimeout,
                      ].any((_) => _ != 0)) ...<Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: informationWidget(
                              'Some build actions have a timeout set.',
                              type: InformationType.info),
                        ),
                      ],
                      Expanded(
                        child: Text(
                            '''
You have a total of ${template.workflowActions.length} action${template.workflowActions.length == 1 ? '' : 's'} that will be executed in order. 

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
                                pubspecPath: (workflowPath.split('\\')
                                          ..removeLast()
                                          ..removeLast())
                                        .join('\\') +
                                    '\\pubspec.yaml',
                                editWorkflowTemplate: template,
                              ),
                            );

                            onReload();
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
