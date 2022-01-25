// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/core/libraries/widgets.dart';
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
                      color: Colors.blueGrey.withOpacity(0.5),
                      padding: EdgeInsets.zero,
                      child: Center(
                        child: Text(
                            _suggestions(widget.workflowActions)
                                .length
                                .toString(),
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    HSeparators.small(),
                    const Text('Suggestions'),
                  ],
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => DialogTemplate(
                      child: Column(
                        children: <Widget>[
                          const DialogHeader(title: 'Suggestions'),
                          ..._suggestions(widget.workflowActions)
                              .map(
                                (String e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: RoundContainer(
                                    color: Colors.blueGrey.withOpacity(0.2),
                                    width: double.infinity,
                                    child: Text(e),
                                  ),
                                ),
                              )
                              .toList(),
                          RectangleButton(
                            width: double.infinity,
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
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
                                  onPressed: () => Navigator.of(context).pop(),
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

List<String> _suggestions(List<WorkflowActionModel> workflowActions) {
  List<String> _suggestions = <String>[];

  // Check to see if the user chose to deploy to web before building.
  // If they did, then we can suggest to build the web before deploying.
  bool _containsBuildWeb = workflowActions.any(
      (WorkflowActionModel e) => e.id == WorkflowActionsIds.buildProjectForWeb);
  bool _containsBuildAndroid = workflowActions.any((WorkflowActionModel e) =>
      e.id == WorkflowActionsIds.buildProjectForAndroid);
  bool _containsBuildIos = workflowActions.any(
      (WorkflowActionModel e) => e.id == WorkflowActionsIds.buildProjectForIOS);
  bool _containsAnalyzeCode = workflowActions.any(
      (WorkflowActionModel e) => e.id == WorkflowActionsIds.analyzeDartProject);
  bool _containsTestCode = workflowActions.any(
      (WorkflowActionModel e) => e.id == WorkflowActionsIds.runProjectTests);
  bool _containsBuildWindows = workflowActions.any((WorkflowActionModel e) =>
      e.id == WorkflowActionsIds.buildProjectForWindows);
  bool _containsBuildMacOS = workflowActions.any((WorkflowActionModel e) =>
      e.id == WorkflowActionsIds.buildProjectForMacOS);
  bool _containsBuildLinux = workflowActions.any((WorkflowActionModel e) =>
      e.id == WorkflowActionsIds.buildProjectForLinux);
  bool _containsDeployWeb = workflowActions.any(
      (WorkflowActionModel e) => e.id == WorkflowActionsIds.deployProjectWeb);

  // If we are deploying web but building after deploying.
  if (_containsBuildWeb && _containsDeployWeb) {
    int _buildWebIndex = workflowActions.indexWhere((WorkflowActionModel e) =>
        e.id == WorkflowActionsIds.buildProjectForWeb);

    int _deployWebIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) => e.id == WorkflowActionsIds.deployProjectWeb);

    if (_buildWebIndex > _deployWebIndex) {
      _suggestions.add(
        'Build the web project before deploying it. You can also build the web project after deploying it.',
      );
    }
  }

  // If we are testing code but analyzing the code after testing.
  if (_containsAnalyzeCode && _containsTestCode) {
    int _analyzeCodeIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) =>
            e.id == WorkflowActionsIds.analyzeDartProject);

    int _testCodeIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) => e.id == WorkflowActionsIds.runProjectTests);

    if (_analyzeCodeIndex > _testCodeIndex) {
      _suggestions.add(
        'Analyze the code before running tests. This way you can be sure there are no syntax errors before running the tests.',
      );
    }
  }

  // If we are testing code after performing web build.
  if (_containsBuildWeb && _containsTestCode) {
    int _buildWebIndex = workflowActions.indexWhere((WorkflowActionModel e) =>
        e.id == WorkflowActionsIds.buildProjectForWeb);

    int _testCodeIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) => e.id == WorkflowActionsIds.runProjectTests);

    if (_buildWebIndex < _testCodeIndex) {
      _suggestions.add(
        'Test the code before building for web. This way we can make sure there are no syntax errors before attempting build.',
      );
    }
  }

  // If we are testing code after performing Android build.
  if (_containsBuildAndroid && _containsTestCode) {
    int _buildAndroidIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) =>
            e.id == WorkflowActionsIds.buildProjectForAndroid);

    int _testCodeIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) => e.id == WorkflowActionsIds.runProjectTests);

    if (_buildAndroidIndex < _testCodeIndex) {
      _suggestions.add(
        'Test the code before building for Android. This way we can make sure there are no syntax errors before attempting build.',
      );
    }
  }

  // If we are testing code after performing iOS build.
  if (_containsBuildIos && _containsTestCode) {
    int _buildIosIndex = workflowActions.indexWhere((WorkflowActionModel e) =>
        e.id == WorkflowActionsIds.buildProjectForIOS);

    int _testCodeIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) => e.id == WorkflowActionsIds.runProjectTests);

    if (_buildIosIndex < _testCodeIndex) {
      _suggestions.add(
        'Test the code before building for iOS. This way we can make sure there are no syntax errors before attempting build.',
      );
    }
  }

  // If we are testing code after performing Windows build.
  if (_containsBuildWindows && _containsTestCode) {
    int _buildWindowsIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) =>
            e.id == WorkflowActionsIds.buildProjectForWindows);

    int _testCodeIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) => e.id == WorkflowActionsIds.runProjectTests);

    if (_buildWindowsIndex < _testCodeIndex) {
      _suggestions.add(
        'Test the code before building for Windows. This way we can make sure there are no syntax errors before attempting build.',
      );
    }
  }

  // If we are testing code after performing macOS build.
  if (_containsBuildMacOS && _containsTestCode) {
    int _buildMacOSIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) =>
            e.id == WorkflowActionsIds.buildProjectForMacOS);

    int _testCodeIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) => e.id == WorkflowActionsIds.runProjectTests);

    if (_buildMacOSIndex < _testCodeIndex) {
      _suggestions.add(
        'Test the code before building for macOS. This way we can make sure there are no syntax errors before attempting build.',
      );
    }
  }

  // If we are testing code after performing Linux build.
  if (_containsBuildLinux && _containsTestCode) {
    int _buildLinuxIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) =>
            e.id == WorkflowActionsIds.buildProjectForLinux);

    int _testCodeIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) => e.id == WorkflowActionsIds.runProjectTests);

    if (_buildLinuxIndex < _testCodeIndex) {
      _suggestions.add(
        'Test the code before building for Linux. This way we can make sure there are no syntax errors before attempting build.',
      );
    }
  }

  // If contains analyze and also a Web build.
  if (_containsAnalyzeCode && _containsBuildWeb) {
    int _analyzeCodeIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) =>
            e.id == WorkflowActionsIds.analyzeDartProject);

    int _buildWebIndex = workflowActions.indexWhere((WorkflowActionModel e) =>
        e.id == WorkflowActionsIds.buildProjectForWeb);

    if (_analyzeCodeIndex > _buildWebIndex) {
      _suggestions.add(
        'Analyze the code before building for web. This way you can be sure there are no syntax errors before building the web.',
      );
    }
  }

  // If contains analyze and also an Android build.
  if (_containsAnalyzeCode && _containsBuildAndroid) {
    int _analyzeCodeIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) =>
            e.id == WorkflowActionsIds.analyzeDartProject);

    int _buildAndroidIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) =>
            e.id == WorkflowActionsIds.buildProjectForAndroid);

    if (_analyzeCodeIndex > _buildAndroidIndex) {
      _suggestions.add(
        'Analyze the code before building for Android. This way you can be sure there are no syntax errors before building the Android.',
      );
    }
  }

  // If contains analyze and also an iOS build.
  if (_containsAnalyzeCode && _containsBuildIos) {
    int _analyzeCodeIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) =>
            e.id == WorkflowActionsIds.analyzeDartProject);

    int _buildIosIndex = workflowActions.indexWhere((WorkflowActionModel e) =>
        e.id == WorkflowActionsIds.buildProjectForIOS);

    if (_analyzeCodeIndex > _buildIosIndex) {
      _suggestions.add(
        'Analyze the code before building for iOS. This way you can be sure there are no syntax errors before building the iOS.',
      );
    }
  }

  // If contains analyze and also a Windows build.
  if (_containsAnalyzeCode && _containsBuildWindows) {
    int _analyzeCodeIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) =>
            e.id == WorkflowActionsIds.analyzeDartProject);

    int _buildWindowsIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) =>
            e.id == WorkflowActionsIds.buildProjectForWindows);

    if (_analyzeCodeIndex > _buildWindowsIndex) {
      _suggestions.add(
        'Analyze the code before building for Windows. This way you can be sure there are no syntax errors before building the Windows.',
      );
    }
  }

  // If contains analyze and also a macOS build.
  if (_containsAnalyzeCode && _containsBuildMacOS) {
    int _analyzeCodeIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) =>
            e.id == WorkflowActionsIds.analyzeDartProject);

    int _buildMacOSIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) =>
            e.id == WorkflowActionsIds.buildProjectForMacOS);

    if (_analyzeCodeIndex > _buildMacOSIndex) {
      _suggestions.add(
        'Analyze the code before building for macOS. This way you can be sure there are no syntax errors before building the MacOS.',
      );
    }
  }

  // If contains analyze and also a Linux build.
  if (_containsAnalyzeCode && _containsBuildLinux) {
    int _analyzeCodeIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) =>
            e.id == WorkflowActionsIds.analyzeDartProject);

    int _buildLinuxIndex = workflowActions.indexWhere(
        (WorkflowActionModel e) =>
            e.id == WorkflowActionsIds.buildProjectForLinux);

    if (_analyzeCodeIndex > _buildLinuxIndex) {
      _suggestions.add(
        'Analyze the code before building for Linux. This way you can be sure there are no syntax errors before building the Linux.',
      );
    }
  }

  return _suggestions;
}
