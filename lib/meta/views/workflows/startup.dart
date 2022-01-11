// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/components/widgets/buttons/square_button.dart';
import 'package:manager/components/widgets/ui/dialog_template.dart';
import 'package:manager/components/widgets/ui/snackbar_tile.dart';
import 'package:manager/components/widgets/ui/spinner.dart';
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/meta/utils/extract_pubspec.dart';
import 'package:manager/meta/views/workflows/actions.dart';
import 'package:manager/meta/views/workflows/models/workflow.dart';
import 'package:manager/meta/views/workflows/sections/actions.dart';
import 'package:manager/meta/views/workflows/sections/configure_actions.dart';
import 'package:manager/meta/views/workflows/sections/confirmation.dart';
import 'package:manager/meta/views/workflows/sections/info.dart';
import 'package:manager/meta/views/workflows/sections/reorder_actions.dart';

class StartUpWorkflow extends StatefulWidget {
  final String? pubspecPath;

  const StartUpWorkflow({Key? key, this.pubspecPath}) : super(key: key);

  @override
  State<StartUpWorkflow> createState() => _StartUpWorkflowState();
}

class _StartUpWorkflowState extends State<StartUpWorkflow> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _webUrlController = TextEditingController();
  final TextEditingController _firebaseProjectName = TextEditingController();
  final TextEditingController _firebaseProjectIDController =
      TextEditingController();

  List<WorkflowActionModel> _workflowActions = <WorkflowActionModel>[];

  PubspecInfo? _pubspecFile;
  bool _forcePubspec = false;

  _InterfaceView _interfaceView = _InterfaceView.workflowInfo;

  // Actions Config
  PlatformBuildModes _iOSBuildMode = PlatformBuildModes.release;
  PlatformBuildModes _androidBuildMode = PlatformBuildModes.release;
  bool _isFirebaseDeployVerified = false;
  WebRenderers _defaultWebRenderer = WebRenderers.canvaskit;
  PlatformBuildModes _defaultWebBuildMode = PlatformBuildModes.release;

  // Utils
  bool _showInfoLast = false;
  bool _saveLocalError = false;
  bool _isSavingLocally = false;

  final ReceivePort _saveLocallyPort = ReceivePort();

  Map<String, dynamic> _lastSavedContent = <String, dynamic>{};

  final Duration _syncIntervals = const Duration(seconds: 20);

  bool _syncStreamListening = false;

  Future<void> _beginSaveMonitor() async {
    while (mounted) {
      Map<String, dynamic> _pendingChanges = WorkflowTemplate(
        name: _nameController.text,
        description: _descriptionController.text,
        webUrl: _webUrlController.text,
        firebaseProjectName: _firebaseProjectName.text,
        firebaseProjectId: _firebaseProjectIDController.text,
        iOSBuildMode: _iOSBuildMode,
        androidBuildMode: _androidBuildMode,
        isFirebaseDeployVerified: _isFirebaseDeployVerified,
        defaultWebRenderer: _defaultWebRenderer,
        defaultWebBuildMode: _defaultWebBuildMode,
        workflowActions:
            _workflowActions.map((WorkflowActionModel e) => e.id).toList(),
      ).toJson();

      List<bool> _stopConditions = <bool>[
        _pendingChanges == _lastSavedContent,
        _pubspecFile == null,
        _nameController.text.isEmpty,
        _interfaceView == _InterfaceView.workflowInfo,
        _interfaceView == _InterfaceView.done,
      ];

      // If the user has not made any changes, no need to save anything.
      if (_stopConditions.contains(true)) {
        // Without this line, app crashes.
        await Future<void>.delayed(_syncIntervals);
        continue;
      }

      setState(() => _isSavingLocally = true);

      Isolate _isolate =
          await Isolate.spawn(_saveWorkflowWithIsolate, <dynamic>[
        _saveLocallyPort.sendPort,
        _pubspecFile?.pathToPubspec ?? widget.pubspecPath,
        _pendingChanges,
        _nameController.text,
      ]).timeout(const Duration(seconds: 5), onTimeout: () {
        setState(() {
          _saveLocalError = true;
          _isSavingLocally = false;
        });
        Isolate.current.kill();
        return Isolate.current;
      });

      if (!_syncStreamListening) {
        setState(() => _syncStreamListening = true);
        _saveLocallyPort.listen((dynamic message) {
          if (message is Map<String, dynamic>) {
            setState(() {
              _lastSavedContent = message;
              _isSavingLocally = false;
              _saveLocalError = false;
            });
          }
          if (message is List) {
            setState(() {
              _isSavingLocally = false;
              _saveLocalError = true;
            });
          }
          _isolate.kill();
        });
      }

      await Future<void>.delayed(_syncIntervals);
    }
  }

  Future<void> _initPubspec() async {
    try {
      String _path = widget.pubspecPath! + '\\pubspec.yaml';
      List<String> _pubspec =
          await File.fromUri(Uri.file(_path, windows: true)).readAsLines();

      setState(() {
        _pubspecFile = extractPubspec(lines: _pubspec, path: _path);
        _forcePubspec = true;
      });
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Couldn\'t read pubspec.yaml file',
          stackTraces: s);
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          snackBarTile(
            context,
            'Couldn\'t read pubspec.yaml file. Invalid permissions set. Please try again.',
            type: SnackBarType.error,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void initState() {
    if (widget.pubspecPath != null) {
      _initPubspec();
    }
    _beginSaveMonitor();
    super.initState();
  }

  @override
  void dispose() {
    _saveLocallyPort.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_pubspecFile == null || widget.pubspecPath == null) {
          return true;
        }

        await _saveWorkflow(
          context,
          showAlerts: true,
          pubspecInfo: _pubspecFile,
          pubspecPath: widget.pubspecPath!,
          template: WorkflowTemplate(
            name: _nameController.text,
            description: _descriptionController.text,
            webUrl: _webUrlController.text,
            firebaseProjectName: _firebaseProjectName.text,
            firebaseProjectId: _firebaseProjectIDController.text,
            iOSBuildMode: _iOSBuildMode,
            androidBuildMode: _androidBuildMode,
            isFirebaseDeployVerified: _isFirebaseDeployVerified,
            defaultWebRenderer: _defaultWebRenderer,
            defaultWebBuildMode: _defaultWebBuildMode,
            workflowActions:
                _workflowActions.map((WorkflowActionModel e) => e.id).toList(),
          ),
        );

        return true;
      },
      child: DialogTemplate(
        onExit: () async {
          if (_pubspecFile == null || widget.pubspecPath == null) {
            Navigator.pop(context);
            return;
          }

          await _saveWorkflow(
            context,
            showAlerts: false,
            pubspecInfo: _pubspecFile,
            pubspecPath: widget.pubspecPath!,
            template: WorkflowTemplate(
              name: _nameController.text,
              description: _descriptionController.text,
              webUrl: _webUrlController.text,
              firebaseProjectName: _firebaseProjectName.text,
              firebaseProjectId: _firebaseProjectIDController.text,
              iOSBuildMode: _iOSBuildMode,
              androidBuildMode: _androidBuildMode,
              isFirebaseDeployVerified: _isFirebaseDeployVerified,
              defaultWebRenderer: _defaultWebRenderer,
              defaultWebBuildMode: _defaultWebBuildMode,
              workflowActions: _workflowActions
                  .map((WorkflowActionModel e) => e.id)
                  .toList(),
            ),
          );

          Navigator.pop(context);
        },
        width: 800,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DialogHeader(
              title: 'New Workflow',
              leading: _interfaceView != _InterfaceView.workflowInfo
                  ? SquareButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      color: Colors.transparent,
                      onPressed: () => setState(() {
                        _showInfoLast = false;
                        _interfaceView =
                            _InterfaceView.values[_interfaceView.index - 1];
                        if (_interfaceView == _InterfaceView.workflowInfo) {
                          _showInfoLast = true;
                        }
                      }),
                    )
                  : null,
              onClose: () async {
                if (_pubspecFile == null || widget.pubspecPath == null) {
                  Navigator.pop(context);
                  return;
                }

                await _saveWorkflow(
                  context,
                  showAlerts: false,
                  pubspecInfo: _pubspecFile,
                  pubspecPath: widget.pubspecPath!,
                  template: WorkflowTemplate(
                    name: _nameController.text,
                    description: _descriptionController.text,
                    webUrl: _webUrlController.text,
                    firebaseProjectName: _firebaseProjectName.text,
                    firebaseProjectId: _firebaseProjectIDController.text,
                    iOSBuildMode: _iOSBuildMode,
                    androidBuildMode: _androidBuildMode,
                    isFirebaseDeployVerified: _isFirebaseDeployVerified,
                    defaultWebRenderer: _defaultWebRenderer,
                    defaultWebBuildMode: _defaultWebBuildMode,
                    workflowActions: _workflowActions
                        .map((WorkflowActionModel e) => e.id)
                        .toList(),
                  ),
                );

                Navigator.pop(context);
              },
            ),
            VSeparators.normal(),
            if (_interfaceView == _InterfaceView.workflowInfo)
              SetProjectWorkflowInfo(
                disableChangePubspec: _forcePubspec,
                showLastPage: _showInfoLast,
                onPubspecUpdate: (PubspecInfo pubspec) =>
                    setState(() => _pubspecFile = pubspec),
                onNext: () {
                  if (_pubspecFile == null) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      snackBarTile(
                        context,
                        'Please select your pubspec.yaml file to continue.',
                        type: SnackBarType.error,
                      ),
                    );
                    return;
                  }
                  setState(
                      () => _interfaceView = _InterfaceView.workflowActions);
                },
                nameController: _nameController,
                descriptionController: _descriptionController,
                pubspecFile: _pubspecFile,
              ),
            if (_interfaceView == _InterfaceView.workflowActions)
              SetProjectWorkflowActions(
                pubspecFile: _pubspecFile!,
                workflowName: _nameController.text,
                workflowDescription: _descriptionController.text,
                projectName: _pubspecFile?.name ?? 'Unknown',
                actions: _workflowActions,
                onActionsUpdate: (List<WorkflowActionModel> actions) =>
                    setState(() => _workflowActions = actions),
                onNext: () {
                  if (_workflowActions.isEmpty) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      snackBarTile(
                        context,
                        'Please select at least one workflow action to continue.',
                        type: SnackBarType.error,
                      ),
                    );
                    return;
                  }
                  setState(
                      () => _interfaceView = _InterfaceView.actionsReorder);
                },
              ),
            if (_interfaceView == _InterfaceView.actionsReorder)
              SetProjectWorkflowActionsOrder(
                workflowName: _nameController.text,
                workflowActions: _workflowActions,
                onReorder: (List<WorkflowActionModel> list) =>
                    setState(() => _workflowActions = list),
                onNext: () => setState(
                    () => _interfaceView = _InterfaceView.configureActions),
              ),
            if (_interfaceView == _InterfaceView.configureActions)
              SetProjectWorkflowActionsConfiguration(
                workflowActions: _workflowActions,
                firebaseProjectIDController: _firebaseProjectIDController,
                firebaseProjectName: _firebaseProjectName,
                webUrlController: _webUrlController,
                defaultIOSBuildMode: _iOSBuildMode,
                oniOSBuildModeChanged: (PlatformBuildModes mode) =>
                    setState(() => _iOSBuildMode = mode),
                defaultAndroidBuildMode: _androidBuildMode,
                onAndroidBuildModeChanged: (PlatformBuildModes mode) =>
                    setState(() => _androidBuildMode = mode),
                isFirebaseValidated: _isFirebaseDeployVerified,
                onFirebaseValidatedChanged: (bool isFirebaseValidated) =>
                    setState(
                        () => _isFirebaseDeployVerified = isFirebaseValidated),
                defaultWebBuildMode: _defaultWebBuildMode,
                defaultWebRenderer: _defaultWebRenderer,
                onBuildWebModeChanged: (PlatformBuildModes mode) =>
                    setState(() => _defaultWebBuildMode = mode),
                onWebRendererChanged: (WebRenderers renderer) =>
                    setState(() => _defaultWebRenderer = renderer),
                onNext: () {
                  if (_workflowActions.any((WorkflowActionModel e) =>
                      e.id == WorkflowActionsIds.deployProjectWeb)) {
                    if (_isFirebaseDeployVerified) {
                      setState(() => _interfaceView = _InterfaceView.done);
                    } else {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        snackBarTile(
                          context,
                          'Please verify your Firebase project info to continue.',
                          type: SnackBarType.error,
                        ),
                      );
                    }
                  } else {
                    setState(() => _interfaceView = _InterfaceView.done);
                  }
                },
              ),
            if (_interfaceView == _InterfaceView.done)
              SetProjectWorkflowConfirmation(
                projectName: _pubspecFile?.name ?? 'Unknown',
                workflowName: _nameController.text,
                workflowDescription: _descriptionController.text,
                onSave: () async {
                  bool _hasSaved = await _saveWorkflow(
                    context,
                    showAlerts: true,
                    pubspecInfo: _pubspecFile,
                    pubspecPath: widget.pubspecPath!,
                    template: WorkflowTemplate(
                      name: _nameController.text,
                      description: _descriptionController.text,
                      webUrl: _webUrlController.text,
                      firebaseProjectName: _firebaseProjectName.text,
                      firebaseProjectId: _firebaseProjectIDController.text,
                      iOSBuildMode: _iOSBuildMode,
                      androidBuildMode: _androidBuildMode,
                      isFirebaseDeployVerified: _isFirebaseDeployVerified,
                      defaultWebRenderer: _defaultWebRenderer,
                      defaultWebBuildMode: _defaultWebBuildMode,
                      workflowActions: _workflowActions
                          .map((WorkflowActionModel e) => e.id)
                          .toList(),
                    ),
                  );

                  if (_hasSaved) {
                    Navigator.pop(context);
                  }
                },
                onSaveAndRun: () async {
                  bool _hasSaved = await _saveWorkflow(
                    context,
                    showAlerts: true,
                    pubspecInfo: _pubspecFile,
                    pubspecPath: widget.pubspecPath!,
                    template: WorkflowTemplate(
                      name: _nameController.text,
                      description: _descriptionController.text,
                      webUrl: _webUrlController.text,
                      firebaseProjectName: _firebaseProjectName.text,
                      firebaseProjectId: _firebaseProjectIDController.text,
                      iOSBuildMode: _iOSBuildMode,
                      androidBuildMode: _androidBuildMode,
                      isFirebaseDeployVerified: _isFirebaseDeployVerified,
                      defaultWebRenderer: _defaultWebRenderer,
                      defaultWebBuildMode: _defaultWebBuildMode,
                      workflowActions: _workflowActions
                          .map((WorkflowActionModel e) => e.id)
                          .toList(),
                    ),
                  );

                  if (_hasSaved) {
                    // TODO: Show the workflow runner.

                    // We now want to run the workflow.
                    ScaffoldMessenger.of(context).showSnackBar(
                      snackBarTile(
                        context,
                        'Running workflows not yet supported/implemented. But workflow saved.',
                        type: SnackBarType.error,
                      ),
                    );
                  }
                },
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: Opacity(
                opacity:
                    (_saveLocalError && !_isSavingLocally || _isSavingLocally)
                        ? 1
                        : 0,
                child: _isSavingLocally
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Tooltip(
                          message:
                              'Saving your workflow data locally so you don\'t lose your work.',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Spinner(size: 10, thickness: 1),
                              HSeparators.small(),
                              const Text(
                                'Syncing workflow...',
                                style:
                                    TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _saveLocalError
                        ? Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Tooltip(
                              message:
                                  'Failed to save your workflow. Please try again. If the problem persists, file an issue.',
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  SvgPicture.asset(Assets.error, height: 10),
                                  HSeparators.small(),
                                  const Text(
                                    'Failed sync...',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _InterfaceView {
  workflowInfo,
  workflowActions,
  actionsReorder,
  configureActions,
  done,
}

Future<void> _saveWorkflowWithIsolate(List<dynamic> data) async {
  // The opened port we can communicate with.
  SendPort _port = data[0];
  Map<String, dynamic> _data = data[2];
  String _projName = data[3];

  try {
    String? _dirPath = data[1];

    if (_dirPath == null || _dirPath.isEmpty || _data.isEmpty) {
      _port.send(_data);
      return;
    }

    _dirPath = (_dirPath.toString().split('\\')..removeLast()).join('\\');

    Directory(_dirPath + '\\fmatic').createSync(recursive: true);

    await File.fromUri(Uri.file(_dirPath + '\\fmatic\\$_projName.json'))
        .writeAsString(jsonEncode(_data))
        .timeout(const Duration(seconds: 3));

    _port.send(_data);
  } catch (_, s) {
    await logger.file(LogTypeTag.error, 'Couldn\'t sync workflow settings.',
        stackTraces: s);
    _port.send(<dynamic>[]);
  }
}

/// Will save the workflow information locally on the user device. Will return
/// either `true` or `false`. `true` means saved successfully. `false` means
/// failed to save.
///
/// This expects a context so that it can show a snackbar if the save fails or
/// succeeds and generally informs the user about the state of the save.
Future<bool> _saveWorkflow(
  BuildContext context, {
  required bool showAlerts,
  required String pubspecPath,
  required WorkflowTemplate template,
  required PubspecInfo? pubspecInfo,
}) async {
  try {
    if (template.name.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      return true;
    }

    // ignore: unawaited_futures
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => const DialogTemplate(
        width: 150,
        height: 100,
        outerTapExit: false,
        child: Spinner(thickness: 2, size: 20),
      ),
    );

    String? _dirPath = pubspecInfo?.pathToPubspec ?? pubspecPath;

    _dirPath = (_dirPath.toString().split('\\')..removeLast()).join('\\');

    await File.fromUri(Uri.file(_dirPath + '\\fmatic\\${template.name}.json'))
        .writeAsString(jsonEncode(template.toJson()))
        .timeout(const Duration(seconds: 3));

    await logger.file(LogTypeTag.info,
        'New workflow created at the following path: ${_dirPath + '\\fmatic\\${template.name}.json'}');

    Navigator.of(context).pop();

    if (showAlerts) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        snackBarTile(
          context,
          'Workflow saved successfully.',
          type: SnackBarType.done,
        ),
      );
    }

    return true;
  } catch (_, s) {
    await logger.file(LogTypeTag.error, 'Couldn\'t save and run workflow.',
        stackTraces: s);

    if (showAlerts) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        snackBarTile(
          context,
          'Couldn\'t save your workflow. Please try again.',
          type: SnackBarType.error,
        ),
      );
    }

    return false;
  }
}
