// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttermatic/app/enum.dart';
import 'package:fluttermatic/meta/utils/general/extract_pubspec.dart';
import 'package:fluttermatic/meta/utils/search/workflow_search.dart';
import 'package:path_provider/path_provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/components/widgets/ui/spinner.dart';
import 'package:fluttermatic/components/widgets/ui/stage_tile.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/views/tabs/sections/projects/models/projects.services.dart';
import 'package:fluttermatic/meta/views/workflows/actions.dart';
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';
import 'package:fluttermatic/meta/views/workflows/runner/runner.dart';
import 'package:fluttermatic/meta/views/workflows/sections/actions.dart';
import 'package:fluttermatic/meta/views/workflows/sections/configure_actions.dart';
import 'package:fluttermatic/meta/views/workflows/sections/confirmation.dart';
import 'package:fluttermatic/meta/views/workflows/sections/info.dart';
import 'package:fluttermatic/meta/views/workflows/sections/reorder_actions.dart';

class StartUpWorkflow extends StatefulWidget {
  final String? pubspecPath;
  final WorkflowTemplate? editWorkflowTemplate;

  const StartUpWorkflow({
    Key? key,
    this.pubspecPath,
    this.editWorkflowTemplate,
  }) : super(key: key);

  @override
  State<StartUpWorkflow> createState() => _StartUpWorkflowState();
}

class _StartUpWorkflowState extends State<StartUpWorkflow> {
  // Utils
  final Duration _syncIntervals = const Duration(seconds: 20);
  final ReceivePort _saveLocallyPort =
      ReceivePort('WORKFLOW_AUTO_SYNC_ISOLATE_PORT');

  // Input Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _webUrlController = TextEditingController();
  final TextEditingController _firebaseProjectName = TextEditingController();
  final TextEditingController _firebaseProjectIDController =
      TextEditingController();

  // Timeout Controllers - (Default is 0, meaning no timeout)
  final TextEditingController _buildAndroidTimeController =
      TextEditingController()..text = '0';
  final TextEditingController _buildIOSTimeController = TextEditingController()
    ..text = '0';
  final TextEditingController _buildMacOSTimeController =
      TextEditingController()..text = '0';
  final TextEditingController _buildLinuxTimeController =
      TextEditingController()..text = '0';
  final TextEditingController _buildWindowsTimeController =
      TextEditingController()..text = '0';
  final TextEditingController _buildWebTimeController = TextEditingController()
    ..text = '0';

  // The list of the workflow actions to run when the workflow is run. This is
  // in order of execution.
  List<WorkflowActionModel> _workflowActions = <WorkflowActionModel>[];

  // List of custom commands in the order to run. This is only empty if workflow
  // actions doesn't have this checked.
  List<String> _customCommands = <String>[];

  // The extracted version of the project pubspec.yaml that we will apply the
  // workflow to.
  PubspecInfo? _pubspecFile;

  // Whether the project pubspec file has been provided to us and we shouldn\'t
  // allow the user to change it. This is typically when we want to show the
  // edit option for the workflow.
  bool _forcePubspec = false;

  // The current view the user sees.
  _InterfaceView _interfaceView = _InterfaceView.workflowInfo;

  // Actions Config Depending on whether or not the user has added the workflow
  // action for each specific one. Not all will be shown to the user depending
  // on the workflow actions they chose.
  AndroidBuildType _androidBuildType = AndroidBuildType.appBundle;
  PlatformBuildModes _androidBuildMode = PlatformBuildModes.release;
  PlatformBuildModes _iOSBuildMode = PlatformBuildModes.release;
  PlatformBuildModes _webBuildMode = PlatformBuildModes.release;
  PlatformBuildModes _windowsBuildMode = PlatformBuildModes.release;
  PlatformBuildModes _macOSBuildMode = PlatformBuildModes.release;
  PlatformBuildModes _linuxBuildMode = PlatformBuildModes.release;
  WebRenderers _webRenderer = WebRenderers.canvaskit;

  // Whether they confirmed Firebase details for auto deploy on web.
  bool _isFirebaseDeployVerified = false;

  // Utils
  bool _showInfoLast = false;
  bool _saveLocalError = false;
  bool _isSavingLocally = false;

  // .gitignore Preferences for this workflow
  bool _addToGitIgnore = false;
  bool _addAllToGitIgnore = false;

  // Store the last saved content. This is used to compare with the new changes,
  // and if there are no changes, we don't need to save because it's the same
  // content (user didn't interact since the last time it was saved).
  Map<String, dynamic> _lastSavedContent = <String, dynamic>{};

  bool _syncStreamListening = false;

  // The project path. This can be fetched from more than one place (either)
  // passed in or the user selects in manually. This provides whichever the
  // case is.
  String get _projectPath =>
      _pubspecFile?.pathToPubspec ?? widget.pubspecPath ?? '';

  // Whether we are syncing in the background or not. This is to show a small
  // indicator to the user.
  bool get _syncing =>
      (_saveLocalError && !_isSavingLocally || _isSavingLocally);

  // Store the workflow template so we can use it anywhere to access the state
  // of the workflow so far.
  WorkflowTemplate _workflowTemplate([bool? isSaved]) {
    return WorkflowTemplate(
      androidBuildTimeout: int.tryParse(_buildAndroidTimeController.text) ?? 0,
      iOSBuildTimeout: int.tryParse(_buildIOSTimeController.text) ?? 0,
      linuxBuildTimeout: int.tryParse(_buildLinuxTimeController.text) ?? 0,
      macosBuildTimeout: int.tryParse(_buildMacOSTimeController.text) ?? 0,
      webBuildTimeout: int.tryParse(_buildWebTimeController.text) ?? 0,
      windowsBuildTimeout: int.tryParse(_buildWindowsTimeController.text) ?? 0,
      name: _nameController.text,
      description: _descriptionController.text,
      webUrl: _webUrlController.text,
      firebaseProjectName: _firebaseProjectName.text,
      firebaseProjectId: _firebaseProjectIDController.text,
      iOSBuildMode: _iOSBuildMode,
      androidBuildType: _androidBuildType,
      androidBuildMode: _androidBuildMode,
      isFirebaseDeployVerified: _isFirebaseDeployVerified,
      webRenderer: _webRenderer,
      webBuildMode: _webBuildMode,
      workflowActions:
          _workflowActions.map((WorkflowActionModel e) => e.id).toList(),
      linuxBuildMode: _linuxBuildMode,
      macosBuildMode: _macOSBuildMode,
      windowsBuildMode: _windowsBuildMode,
      customCommands: _customCommands,
      isSaved: isSaved ?? false,
    );
  }

  Future<void> _beginSaveMonitor() async {
    while (mounted) {
      List<bool> stopConditions = <bool>[
        (_workflowTemplate().toJson()) == _lastSavedContent,
        _pubspecFile == null,
        _nameController.text.isEmpty,
        _interfaceView == _InterfaceView.workflowInfo,
        _interfaceView == _InterfaceView.done,
      ];

      // If the user has not made any changes, no need to save anything.
      if (stopConditions.contains(true)) {
        // Without this line, app crashes.
        await Future<void>.delayed(_syncIntervals);
        continue;
      }

      setState(() => _isSavingLocally = true);

      Isolate i = await Isolate.spawn(_saveInBgSync, <dynamic>[
        _saveLocallyPort.sendPort,
        _projectPath,
        _workflowTemplate().toJson(),
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
          i.kill();
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
        });
      }

      await Future<void>.delayed(_syncIntervals);
    }
  }

  Future<void> _initPubspec() async {
    try {
      String path = _projectPath.endsWith('\\pubspec.yaml')
          ? _projectPath
          : ('$_projectPath\\pubspec.yaml');

      List<String> pubspec = await File(path).readAsLines();

      setState(() {
        _pubspecFile = extractPubspec(lines: pubspec, path: path);
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

  void _prepareEditSession() {
    assert(widget.editWorkflowTemplate != null && widget.pubspecPath != null,
        'To provide an edit workflow template, you must provide the path to the project pubspec.yaml file which contains the workflow.');

    setState(() {
      _nameController.text = widget.editWorkflowTemplate?.name ?? '';
      _descriptionController.text =
          widget.editWorkflowTemplate?.description ?? '';
      _webUrlController.text = widget.editWorkflowTemplate?.webUrl ?? '';
      _firebaseProjectName.text =
          widget.editWorkflowTemplate?.firebaseProjectName ?? '';
      _firebaseProjectIDController.text =
          widget.editWorkflowTemplate?.firebaseProjectId ?? '';

      // Set the timeouts
      _buildAndroidTimeController.text =
          widget.editWorkflowTemplate?.androidBuildTimeout.toString() ?? '0';
      _buildIOSTimeController.text =
          widget.editWorkflowTemplate?.iOSBuildTimeout.toString() ?? '0';
      _buildLinuxTimeController.text =
          widget.editWorkflowTemplate?.linuxBuildTimeout.toString() ?? '0';
      _buildMacOSTimeController.text =
          widget.editWorkflowTemplate?.macosBuildTimeout.toString() ?? '0';
      _buildWebTimeController.text =
          widget.editWorkflowTemplate?.webBuildTimeout.toString() ?? '0';
      _buildWindowsTimeController.text =
          widget.editWorkflowTemplate?.windowsBuildTimeout.toString() ?? '0';

      // Set the build modes & types
      _iOSBuildMode = widget.editWorkflowTemplate?.iOSBuildMode ??
          PlatformBuildModes.release;
      _androidBuildMode = widget.editWorkflowTemplate?.androidBuildMode ??
          PlatformBuildModes.release;
      _webRenderer =
          widget.editWorkflowTemplate?.webRenderer ?? WebRenderers.canvaskit;
      _webBuildMode = widget.editWorkflowTemplate?.webBuildMode ??
          PlatformBuildModes.release;
      _isFirebaseDeployVerified =
          widget.editWorkflowTemplate?.isFirebaseDeployVerified ?? false;
      _linuxBuildMode = widget.editWorkflowTemplate?.linuxBuildMode ??
          PlatformBuildModes.release;
      _macOSBuildMode = widget.editWorkflowTemplate?.macosBuildMode ??
          PlatformBuildModes.release;
      _windowsBuildMode = widget.editWorkflowTemplate?.windowsBuildMode ??
          PlatformBuildModes.release;
      if (widget.editWorkflowTemplate?.workflowActions == null) {
        _workflowActions = <WorkflowActionModel>[];
      } else {
        _workflowActions =
            widget.editWorkflowTemplate!.workflowActions.map((String e) {
          return WorkflowActionModel(
            id: e,
            name: workflowActionModels
                .where((WorkflowActionModel action) => action.id == e)
                .first
                .name,
            description: workflowActionModels
                .where((WorkflowActionModel action) => action.id == e)
                .first
                .description,
            type: workflowActionModels
                .where((WorkflowActionModel action) => action.id == e)
                .first
                .type,
          );
        }).toList();
      }
    });

    logger.file(
        LogTypeTag.info, 'Workflow template loaded. Beginning edit session.');
  }

  @override
  void initState() {
    if (widget.pubspecPath != null) {
      _initPubspec();
    }
    if (widget.editWorkflowTemplate != null) {
      _prepareEditSession();
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
        if (_pubspecFile == null || _projectPath.isEmpty) {
          return true;
        }

        await _saveWorkflow(
          context,
          showAlerts: true,
          pubspecInfo: _pubspecFile,
          pubspecPath: _projectPath,
          addToGitignore: _addToGitIgnore,
          addAllToGitignore: _addAllToGitIgnore,
          template: _workflowTemplate(),
        );

        return true;
      },
      child: DialogTemplate(
        onExit: () async {
          if (_pubspecFile == null || _projectPath.isEmpty) {
            Navigator.pop(context);
            return;
          }

          await _saveWorkflow(
            context,
            showAlerts: false,
            pubspecInfo: _pubspecFile,
            pubspecPath: _projectPath,
            addToGitignore: _addToGitIgnore,
            addAllToGitignore: _addAllToGitIgnore,
            template: _workflowTemplate(),
          );

          if (mounted) {
            Navigator.pop(context);
          }
        },
        width: 800,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DialogHeader(
              title: widget.editWorkflowTemplate != null
                  ? 'Edit Workflow'
                  : 'New Workflow',
              leading: _interfaceView != _InterfaceView.workflowInfo
                  ? SquareButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
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
                  : const StageTile(stageType: StageType.beta),
              onClose: () async {
                if (_pubspecFile == null || _projectPath.isEmpty) {
                  Navigator.pop(context);
                  return;
                }

                await _saveWorkflow(
                  context,
                  showAlerts: false,
                  pubspecInfo: _pubspecFile,
                  pubspecPath: _projectPath,
                  addToGitignore: _addToGitIgnore,
                  addAllToGitignore: _addAllToGitIgnore,
                  template: _workflowTemplate(),
                );

                if (mounted) {
                  Navigator.pop(context);
                }
              },
            ),
            if (_interfaceView == _InterfaceView.workflowInfo)
              SetProjectWorkflowInfo(
                disableChangePubspec: _forcePubspec,
                showLastPage:
                    _showInfoLast || widget.editWorkflowTemplate != null,
                onPubspecUpdate: (_) => setState(() => _pubspecFile = _),
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
                onActionsUpdate: (_) => setState(() => _workflowActions = _),
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
                onReorder: (_) => setState(() => _workflowActions = _),
                onNext: () => setState(
                    () => _interfaceView = _InterfaceView.configureActions),
              ),
            if (_interfaceView == _InterfaceView.configureActions)
              SetProjectWorkflowActionsConfiguration(
                buildAndroidTimeController: _buildAndroidTimeController,
                buildIOSTimeController: _buildIOSTimeController,
                buildLinuxTimeController: _buildLinuxTimeController,
                buildMacOSTimeController: _buildMacOSTimeController,
                buildWindowsTimeController: _buildWindowsTimeController,
                buildWebTimeController: _buildWebTimeController,
                workflowActions: _workflowActions,
                webUrlController: _webUrlController,
                firebaseProjectName: _firebaseProjectName,
                firebaseProjectIDController: _firebaseProjectIDController,
                onFirebaseValidatedChanged: (_) =>
                    setState(() => _isFirebaseDeployVerified = _),
                isFirebaseValidated: _isFirebaseDeployVerified,
                defaultWebBuildMode: _webBuildMode,
                defaultIOSBuildMode: _iOSBuildMode,
                androidBuildType: _androidBuildType,
                defaultAndroidBuildMode: _androidBuildMode,
                defaultLinuxBuildMode: _linuxBuildMode,
                defaultMacOSBuildMode: _macOSBuildMode,
                defaultWindowsBuildMode: _windowsBuildMode,
                defaultWebRenderer: _webRenderer,
                customCommands: _customCommands,
                oniOSBuildModeChanged: (_) => setState(() => _iOSBuildMode = _),
                onAndroidBuildTypeChanged: (_) =>
                    setState(() => _androidBuildType = _),
                onAndroidBuildModeChanged: (_) =>
                    setState(() => _androidBuildMode = _),
                onBuildWebModeChanged: (_) => setState(() => _webBuildMode = _),
                onLinuxBuildModeChanged: (_) =>
                    setState(() => _linuxBuildMode = _),
                onMacOSBuildModeChanged: (_) =>
                    setState(() => _macOSBuildMode = _),
                onWindowsBuildModeChanged: (_) =>
                    setState(() => _windowsBuildMode = _),
                onWebRendererChanged: (_) => setState(() => _webRenderer = _),
                onCustomCommandsChanged: (_) =>
                    setState(() => _customCommands = _),
                onNext: () {
                  // Make sure if we have custom commands that there is at
                  // least one command set.
                  if (_workflowActions.any((_) =>
                          _.id == WorkflowActionsIds.runCustomCommands) &&
                      _customCommands.isEmpty) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      snackBarTile(
                        context,
                        'Please enter at least one custom command to continue.',
                        type: SnackBarType.error,
                      ),
                    );
                    return;
                  }

                  // See if we have deploy web project to Firebase enabled but
                  // not validated.
                  if (_workflowActions.any(
                          (_) => _.id == WorkflowActionsIds.deployProjectWeb) &&
                      !_isFirebaseDeployVerified) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      snackBarTile(
                        context,
                        'Please verify your Firebase project info to continue.',
                        type: SnackBarType.error,
                      ),
                    );
                    return;
                  }

                  setState(() => _interfaceView = _InterfaceView.done);
                },
              ),
            if (_interfaceView == _InterfaceView.done)
              SetProjectWorkflowConfirmation(
                addToGitignore: _addToGitIgnore,
                addAllToGitignore: _addAllToGitIgnore,
                onAddAllToGitignore: () => setState(() {
                  if (_addToGitIgnore) {
                    _addToGitIgnore = false;
                  }
                  _addAllToGitIgnore = !_addAllToGitIgnore;
                }),
                onAddToGitignore: () => setState(() {
                  if (_addAllToGitIgnore) {
                    _addAllToGitIgnore = false;
                  }
                  _addToGitIgnore = !_addToGitIgnore;
                }),
                projectName: _pubspecFile?.name ?? 'Unknown',
                workflowName: _nameController.text,
                workflowDescription: _descriptionController.text,
                onSave: () async {
                  bool hasSaved = await _saveWorkflow(
                    context,
                    showAlerts: true,
                    pubspecInfo: _pubspecFile,
                    pubspecPath: _projectPath,
                    addToGitignore: _addToGitIgnore,
                    addAllToGitignore: _addAllToGitIgnore,
                    template: _workflowTemplate(true),
                  );

                  if (hasSaved) {
                    // Update the cache with the new changes
                    await WorkflowSearchUtils.getWorkflowsFromPath(
                        cache: await ProjectServicesModel.getProjectCache(
                                (await getApplicationSupportDirectory())
                                    .path) ??
                            const ProjectCacheResult(
                              projectsPath: null,
                              refreshIntervals: null,
                              lastProjectReload: null,
                              lastWorkflowsReload: null,
                            ),
                        supportDir:
                            (await getApplicationSupportDirectory()).path);

                    if (mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                onSaveAndRun: () async {
                  bool hasSaved = await _saveWorkflow(
                    context,
                    showAlerts: true,
                    pubspecInfo: _pubspecFile,
                    pubspecPath: _projectPath,
                    addToGitignore: _addToGitIgnore,
                    addAllToGitignore: _addAllToGitIgnore,
                    template: _workflowTemplate(true),
                  );

                  if (hasSaved) {
                    // Update the cache with the new changes
                    await WorkflowSearchUtils.getWorkflowsFromPath(
                        cache: await ProjectServicesModel.getProjectCache(
                                (await getApplicationSupportDirectory())
                                    .path) ??
                            const ProjectCacheResult(
                              projectsPath: null,
                              refreshIntervals: null,
                              lastProjectReload: null,
                              lastWorkflowsReload: null,
                            ),
                        supportDir:
                            (await getApplicationSupportDirectory()).path);

                    if (mounted) {
                      Navigator.pop(context);
                    }

                    String? path =
                        (_projectPath.split('\\')..removeLast()).join('\\');

                    if (path.isEmpty) {
                      await logger.file(LogTypeTag.error,
                          'Could not get path to show workflow runner at save and run.');

                      if (mounted) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
                            context,
                            'Failed to open Workflow Runner. Try opening the runner from the projects tab.',
                            type: SnackBarType.error));
                      }
                      return;
                    }

                    await showDialog(
                      context: context,
                      builder: (_) => WorkflowRunnerDialog(
                        workflowPath:
                            '$path\\$fmWorkflowDir\\${_nameController.text}.json',
                      ),
                    );
                  }
                },
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: AnimatedOpacity(
                opacity: _syncing ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Builder(builder: (_) {
                  if (_isSavingLocally) {
                    return Padding(
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
                    );
                  } else if (_saveLocalError) {
                    return Padding(
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
                              style:
                                  TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
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

Future<void> _saveInBgSync(List<dynamic> data) async {
  // The opened port we can communicate with.
  SendPort port = data[0];
  Map<String, dynamic> content = data[2];
  String projName = content[3];

  try {
    String? dirPath = content[1];

    if (dirPath == null || dirPath.isEmpty || content.isEmpty) {
      port.send(content);
      return;
    }

    dirPath = (dirPath.toString().split('\\')..removeLast()).join('\\');

    Directory('$dirPath\\$fmWorkflowDir').createSync(recursive: true);

    await File.fromUri(Uri.file('$dirPath\\$fmWorkflowDir\\$projName.json'))
        .writeAsString(jsonEncode(content))
        .timeout(const Duration(seconds: 3));

    port.send(content);
    return;
  } catch (_, s) {
    await logger.file(LogTypeTag.error, 'Couldn\'t sync workflow settings.',
        stackTraces: s);
    port.send(<dynamic>[]);
    return;
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
  required bool addToGitignore,
  required bool addAllToGitignore,
  required bool showAlerts,
  required String pubspecPath,
  required WorkflowTemplate template,
  required PubspecInfo? pubspecInfo,
}) async {
  NavigatorState navigator = Navigator.of(context);

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

    String? dirPath = pubspecInfo?.pathToPubspec ?? pubspecPath;

    dirPath = (dirPath.toString().split('\\')..removeLast()).join('\\');

    await Directory('$dirPath\\$fmWorkflowDir').create(recursive: true);

    await File.fromUri(
            Uri.file('$dirPath\\$fmWorkflowDir\\${template.name}.json'))
        .writeAsString(jsonEncode(template.toJson()))
        .timeout(const Duration(seconds: 3));

    // If we saved the project, meaning that this is the final step (user done
    // setting up the workflow), then we will see if we have to add anything
    // to .gitignore.
    if (template.isSaved && (addToGitignore || addAllToGitignore)) {
      String addComment =
          '# Specific FlutterMatic workflow hidden: ${template.name}';
      String addAllComment = '# All FlutterMatic workflows are hidden.';

      try {
        File git = File('$dirPath\\.gitignore');

        // Create the .gitignore file if it doesn't exist.
        if (!await git.exists()) {
          await git.writeAsString('').timeout(const Duration(seconds: 3));
        }

        List<String> gitignoreFile = await git.readAsLines();

        // We will add the comment if it doesn't already exist.
        if ((addToGitignore && !gitignoreFile.contains(addComment)) ||
            (addAllToGitignore && !gitignoreFile.contains(addAllComment))) {
          await git
              .writeAsString(
                  '\n${addToGitignore ? addComment : addAllComment}\n',
                  mode: FileMode.append)
              .timeout(const Duration(seconds: 3));
        }

        // Make sure it doesn't already exist.
        if (addToGitignore &&
            !gitignoreFile.contains('$fmWorkflowDir/${template.name}.json')) {
          await git
              .writeAsString('$fmWorkflowDir/${template.name}.json\n',
                  mode: FileMode.append)
              .timeout(const Duration(seconds: 3));
        } else if (addAllToGitignore &&
            !gitignoreFile.contains('$fmWorkflowDir/')) {
          await git
              .writeAsString('$fmWorkflowDir/\n', mode: FileMode.append)
              .timeout(const Duration(seconds: 3));
        }
      } catch (_, s) {
        await logger.file(
            LogTypeTag.error, 'Couldn\'t add to .gitignore for workflow: $_',
            stackTraces: s);
      }
    }

    await logger.file(LogTypeTag.info,
        'New workflow created at the following path: ${'$dirPath\\$fmWorkflowDir\\${template.name}.json'}');

    if (navigator.mounted) {
      navigator.pop();
    }

    if (showAlerts && navigator.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        snackBarTile(
          context,
          template.isSaved
              ? 'Workflow saved successfully. You can find it in the "Workflows" tab.'
              : 'We stored a copy of this workflow so you can continue editing it later.',
          type: SnackBarType.done,
        ),
      );
    }

    return true;
  } catch (_, s) {
    await logger.file(LogTypeTag.error, 'Couldn\'t save and run workflow: $_',
        stackTraces: s);

    if (navigator.mounted) {
      navigator.pop();
    }

    if (showAlerts && navigator.mounted) {
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
