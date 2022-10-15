// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/meta/views/workflows/actions.dart';

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
          infoWidget(
            context,
            'You can order your workflow actions to set the order they are executed in your ${widget.workflowName} workflow.',
          ),
        VSeparators.normal(),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: ConstrainedBox(
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
                        '${i + 1} - ',
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
                  WorkflowActionModel item =
                      _workflowActions.removeAt(oldIndex);
                  _workflowActions.insert(newIndex, item);
                });

                widget.onReorder(_workflowActions);
              },
            ),
          ),
        ),
        VSeparators.normal(),
        Row(
          children: <Widget>[
            if (_suggestions(widget.workflowActions).isNotEmpty)
              RectangleButton(
                width: 140,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    RoundContainer(
                      width: 20,
                      height: 20,
                      radius: 50,
                      color: Colors.blueGrey.withOpacity(0.2),
                      padding: EdgeInsets.zero,
                      child: Center(
                        child: Text(
                            _suggestions(widget.workflowActions)
                                .length
                                .toString(),
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    HSeparators.small(),
                    Text(
                        'Suggestion${_suggestions(widget.workflowActions).length == 1 ? '' : 's'}'),
                  ],
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => _ShowSuggestionsDialog(
                        workflowActions: _workflowActions),
                  );
                },
              ),
            const Spacer(),
            RectangleButton(
              width: 100,
              child: const Text('Next'),
              onPressed: () {
                if (_suggestions(widget.workflowActions).isNotEmpty) {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (_) => DialogTemplate(
                      child: Column(
                        children: <Widget>[
                          const DialogHeader(
                              title: 'Ignore Suggestions?', canClose: false),
                          const Text(
                            'You have suggested changes recommended for your workflow. Are you sure you want to continue?',
                            textAlign: TextAlign.center,
                          ),
                          VSeparators.large(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: RectangleButton(
                                  child: const Text('View Suggestions'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    showDialog(
                                      context: context,
                                      builder: (_) => _ShowSuggestionsDialog(
                                          workflowActions: _workflowActions),
                                    );
                                  },
                                ),
                              ),
                              HSeparators.normal(),
                              Expanded(
                                child: RectangleButton(
                                  child: const Text('Continue'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    widget.onNext();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  widget.onNext();
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _ShowSuggestionsDialog extends StatelessWidget {
  final List<WorkflowActionModel> workflowActions;
  const _ShowSuggestionsDialog({
    Key? key,
    required this.workflowActions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          const DialogHeader(title: 'Suggestions'),
          ..._suggestions(workflowActions)
              .map(
                (String e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: RoundContainer(
                    width: double.infinity,
                    child: Text(e),
                  ),
                ),
              )
              .toList(),
          RectangleButton(
            width: double.infinity,
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

List<String> _suggestions(List<WorkflowActionModel> workflowActions) {
  List<String> suggestions = <String>[];

  // Check to see if the user chose to deploy to web before building.
  // If they did, then we can suggest to build the web before deploying.
  bool containsBuildWeb = workflowActions.any(
      (WorkflowActionModel e) => e.id == WorkflowActionsIds.buildProjectForWeb);
  bool containsBuildAndroid = workflowActions.any((WorkflowActionModel e) =>
      e.id == WorkflowActionsIds.buildProjectForAndroid);
  bool containsBuildIos = workflowActions.any(
      (WorkflowActionModel e) => e.id == WorkflowActionsIds.buildProjectForIOS);
  bool containsAnalyzeCode = workflowActions.any(
      (WorkflowActionModel e) => e.id == WorkflowActionsIds.analyzeDartProject);
  bool containsTestCode = workflowActions.any(
      (WorkflowActionModel e) => e.id == WorkflowActionsIds.runProjectTests);
  bool containsBuildWindows = workflowActions.any((WorkflowActionModel e) =>
      e.id == WorkflowActionsIds.buildProjectForWindows);
  bool containsBuildMacOS = workflowActions.any((WorkflowActionModel e) =>
      e.id == WorkflowActionsIds.buildProjectForMacOS);
  bool containsBuildLinux = workflowActions.any((WorkflowActionModel e) =>
      e.id == WorkflowActionsIds.buildProjectForLinux);
  bool containsDeployWeb = workflowActions.any(
      (WorkflowActionModel e) => e.id == WorkflowActionsIds.deployProjectWeb);

  // If we are deploying web but building after deploying.
  if (containsBuildWeb && containsDeployWeb) {
    int buildWebIndex = workflowActions.indexWhere((WorkflowActionModel e) =>
        e.id == WorkflowActionsIds.buildProjectForWeb);

    int deployWebIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) => e.id == WorkflowActionsIds.deployProjectWeb);

    if (buildWebIndex > deployWebIndex) {
      suggestions.add(
        'Build the web project before deploying it. You can also build the web project after deploying it.',
      );
    }
  }

  // If we are testing code but analyzing the code after testing.
  if (containsAnalyzeCode && containsTestCode) {
    int analyzeCodeIndex = workflowActions.indexWhere((WorkflowActionModel e) =>
        e.id == WorkflowActionsIds.analyzeDartProject);

    int testCodeIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) => e.id == WorkflowActionsIds.runProjectTests);

    if (analyzeCodeIndex > testCodeIndex) {
      suggestions.add(
        'Analyze the code before running tests. This way you can be sure there are no syntax errors before running the tests.',
      );
    }
  }

  // If we are testing code after performing web build.
  if (containsBuildWeb && containsTestCode) {
    int buildWebIndex = workflowActions.indexWhere((WorkflowActionModel e) =>
        e.id == WorkflowActionsIds.buildProjectForWeb);

    int testCodeIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) => e.id == WorkflowActionsIds.runProjectTests);

    if (buildWebIndex < testCodeIndex) {
      suggestions.add(
        'Test the code before building for web. This way we can make sure there are no syntax errors before attempting build.',
      );
    }
  }

  // If we are testing code after performing Android build.
  if (containsBuildAndroid && containsTestCode) {
    int buildAndroidIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) =>
            e.id == WorkflowActionsIds.buildProjectForAndroid);

    int testCodeIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) => e.id == WorkflowActionsIds.runProjectTests);

    if (buildAndroidIndex < testCodeIndex) {
      suggestions.add(
        'Test the code before building for Android. This way we can make sure there are no syntax errors before attempting build.',
      );
    }
  }

  // If we are testing code after performing iOS build.
  if (containsBuildIos && containsTestCode) {
    int buildIosIndex = workflowActions.indexWhere((WorkflowActionModel e) =>
        e.id == WorkflowActionsIds.buildProjectForIOS);

    int testCodeIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) => e.id == WorkflowActionsIds.runProjectTests);

    if (buildIosIndex < testCodeIndex) {
      suggestions.add(
        'Test the code before building for iOS. This way we can make sure there are no syntax errors before attempting build.',
      );
    }
  }

  // If we are testing code after performing Windows build.
  if (containsBuildWindows && containsTestCode) {
    int buildWindowsIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) =>
            e.id == WorkflowActionsIds.buildProjectForWindows);

    int testCodeIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) => e.id == WorkflowActionsIds.runProjectTests);

    if (buildWindowsIndex < testCodeIndex) {
      suggestions.add(
        'Test the code before building for Windows. This way we can make sure there are no syntax errors before attempting build.',
      );
    }
  }

  // If we are testing code after performing macOS build.
  if (containsBuildMacOS && containsTestCode) {
    int buildMacOSIndex = workflowActions.indexWhere((WorkflowActionModel e) =>
        e.id == WorkflowActionsIds.buildProjectForMacOS);

    int testCodeIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) => e.id == WorkflowActionsIds.runProjectTests);

    if (buildMacOSIndex < testCodeIndex) {
      suggestions.add(
        'Test the code before building for macOS. This way we can make sure there are no syntax errors before attempting build.',
      );
    }
  }

  // If we are testing code after performing Linux build.
  if (containsBuildLinux && containsTestCode) {
    int buildLinuxIndex = workflowActions.indexWhere((WorkflowActionModel e) =>
        e.id == WorkflowActionsIds.buildProjectForLinux);

    int testCodeIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) => e.id == WorkflowActionsIds.runProjectTests);

    if (buildLinuxIndex < testCodeIndex) {
      suggestions.add(
        'Test the code before building for Linux. This way we can make sure there are no syntax errors before attempting build.',
      );
    }
  }

  // If contains analyze and also a Web build.
  if (containsAnalyzeCode && containsBuildWeb) {
    int analyzeCodeIndex = workflowActions.indexWhere((WorkflowActionModel e) =>
        e.id == WorkflowActionsIds.analyzeDartProject);

    int buildWebIndex = workflowActions.indexWhere((WorkflowActionModel e) =>
        e.id == WorkflowActionsIds.buildProjectForWeb);

    if (analyzeCodeIndex > buildWebIndex) {
      suggestions.add(
        'Analyze the code before building for web. This way you can be sure there are no syntax errors before building the web.',
      );
    }
  }

  // If contains analyze and also an Android build.
  if (containsAnalyzeCode && containsBuildAndroid) {
    int analyzeCodeIndex = workflowActions.indexWhere((WorkflowActionModel e) =>
        e.id == WorkflowActionsIds.analyzeDartProject);

    int buildAndroidIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) =>
            e.id == WorkflowActionsIds.buildProjectForAndroid);

    if (analyzeCodeIndex > buildAndroidIndex) {
      suggestions.add(
        'Analyze the code before building for Android. This way you can be sure there are no syntax errors before building the Android.',
      );
    }
  }

  // If contains analyze and also an iOS build.
  if (containsAnalyzeCode && containsBuildIos) {
    int analyzeCodeIndex = workflowActions.indexWhere((WorkflowActionModel e) =>
        e.id == WorkflowActionsIds.analyzeDartProject);

    int buildIosIndex = workflowActions.indexWhere((WorkflowActionModel e) =>
        e.id == WorkflowActionsIds.buildProjectForIOS);

    if (analyzeCodeIndex > buildIosIndex) {
      suggestions.add(
        'Analyze the code before building for iOS. This way you can be sure there are no syntax errors before building the iOS.',
      );
    }
  }

  // If contains analyze and also a Windows build.
  if (containsAnalyzeCode && containsBuildWindows) {
    int analyzeCodeIndex = workflowActions.indexWhere((WorkflowActionModel e) =>
        e.id == WorkflowActionsIds.analyzeDartProject);

    int buildWindowsIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) =>
            e.id == WorkflowActionsIds.buildProjectForWindows);

    if (analyzeCodeIndex > buildWindowsIndex) {
      suggestions.add(
        'Analyze the code before building for Windows. This way you can be sure there are no syntax errors before building the Windows.',
      );
    }
  }

  // If contains analyze and also a macOS build.
  if (containsAnalyzeCode && containsBuildMacOS) {
    int analyzeCodeIndex = workflowActions.indexWhere((WorkflowActionModel e) =>
        e.id == WorkflowActionsIds.analyzeDartProject);

    int buildMacOSIndex = workflowActions.indexWhere((WorkflowActionModel e) =>
        e.id == WorkflowActionsIds.buildProjectForMacOS);

    if (analyzeCodeIndex > buildMacOSIndex) {
      suggestions.add(
        'Analyze the code before building for macOS. This way you can be sure there are no syntax errors before building the MacOS.',
      );
    }
  }

  // If contains analyze and also a Linux build.
  if (containsAnalyzeCode && containsBuildLinux) {
    int analyzeCodeIndex = workflowActions.indexWhere((WorkflowActionModel e) =>
        e.id == WorkflowActionsIds.analyzeDartProject);

    int buildLinuxIndex = workflowActions.indexWhere((WorkflowActionModel e) =>
        e.id == WorkflowActionsIds.buildProjectForLinux);

    if (analyzeCodeIndex > buildLinuxIndex) {
      suggestions.add(
        'Analyze the code before building for Linux. This way you can be sure there are no syntax errors before building the Linux.',
      );
    }
  }

  return suggestions;
}
