// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/enum.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/components/widgets/ui/stage_tile.dart';
import 'package:fluttermatic/core/notifiers/models/state/actions/workflows.dart';
import 'package:fluttermatic/core/notifiers/notifiers/actions/workflows.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/general/extract_pubspec.dart';
import 'package:fluttermatic/meta/views/workflows/actions.dart';
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';
import 'package:fluttermatic/meta/views/workflows/runner/runner.dart';
import 'package:fluttermatic/meta/views/workflows/sections/actions.dart';
import 'package:fluttermatic/meta/views/workflows/sections/configure_actions.dart';
import 'package:fluttermatic/meta/views/workflows/sections/confirmation.dart';
import 'package:fluttermatic/meta/views/workflows/sections/info.dart';
import 'package:fluttermatic/meta/views/workflows/sections/reorder_actions.dart';

class StartUpWorkflow extends StatefulWidget {
  // The pubspec path to create a new project in.
  final String? pubspecPath;

  // The workflow to continue working or editing on.
  final WorkflowTemplate? workflow;

  const StartUpWorkflow({
    Key? key,
    this.pubspecPath,
    this.workflow,
  }) : super(key: key);

  @override
  State<StartUpWorkflow> createState() => _StartUpWorkflowState();
}

class _StartUpWorkflowState extends State<StartUpWorkflow> {
  // Utils
  final Duration _syncIntervals = const Duration(seconds: 20);

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

  // .gitignore Preferences for this workflow
  bool _addToGitIgnore = false;
  bool _addAllToGitIgnore = false;

  // Store the last saved content. This is used to compare with the new changes,
  // and if there are no changes, we don't need to save because it's the same
  // content (user didn't interact since the last time it was saved).
  Map<String, dynamic> _lastSavedContent = <String, dynamic>{};

  // The project path. This can be fetched from more than one place (either)
  // passed in or the user selects in manually. This provides whichever the
  // case is.
  String get _pubspecPath =>
      _pubspecFile?.pathToPubspec ?? widget.pubspecPath ?? '';

  // Whether we are syncing in the background or not. This is to show a small
  // indicator to the user.

  // Store the workflow template so we can use it anywhere to access the state
  // of the workflow so far.
  WorkflowTemplate _workflowTemplate([bool? isSaved]) {
    return WorkflowTemplate(
      name: _nameController.text,
      description: _descriptionController.text,
      workflowPath:
          '${(_pubspecPath.split('\\')..removeLast()).join('\\')}\\$fmWorkflowDir\\${_nameController.text}.json',
      androidBuildTimeout: int.tryParse(_buildAndroidTimeController.text) ?? 0,
      iOSBuildTimeout: int.tryParse(_buildIOSTimeController.text) ?? 0,
      linuxBuildTimeout: int.tryParse(_buildLinuxTimeController.text) ?? 0,
      macosBuildTimeout: int.tryParse(_buildMacOSTimeController.text) ?? 0,
      webBuildTimeout: int.tryParse(_buildWebTimeController.text) ?? 0,
      windowsBuildTimeout: int.tryParse(_buildWindowsTimeController.text) ?? 0,
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
        await Future<void>.delayed(_syncIntervals);
        continue;
      }

      String pubspecPath = '';

      await Future.sync(() async {
        try {
          pubspecPath = (pubspecPath.split('\\')..removeLast()).join('\\');

          Directory workflowsDir = Directory('$pubspecPath\\$fmWorkflowDir');

          await workflowsDir.create(recursive: true);

          await File('${workflowsDir.path}\\${_workflowTemplate().name}.json')
              .writeAsString(jsonEncode(_workflowTemplate().toJson()))
              .timeout(const Duration(seconds: 3));

          await logger.file(LogTypeTag.info,
              'Synced workflow settings in the background for ${_workflowTemplate().name} at ${DateTime.now()} in ${workflowsDir.path}');

          setState(() {
            _lastSavedContent = _workflowTemplate().toJson();
            _saveLocalError = false;
          });
        } catch (_, s) {
          await logger.file(
              LogTypeTag.error, 'Couldn\'t sync workflow settings.',
              stackTraces: s);

          setState(() => _saveLocalError = true);
        }
      }).timeout(const Duration(seconds: 3), onTimeout: () async {
        await logger.file(LogTypeTag.error,
            'Couldn\'t sync workflow settings. Timeout triggered.');

        setState(() => _saveLocalError = true);
      });

      await Future<void>.delayed(_syncIntervals);
    }
  }

  Future<void> _initPubspec() async {
    try {
      List<String> pubspec = await File(_pubspecPath).readAsLines();

      setState(() {
        _pubspecFile = extractPubspec(lines: pubspec, path: _pubspecPath);
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
    assert(widget.workflow != null && widget.pubspecPath != null,
        'To provide an edit workflow template, you must provide the path to the project pubspec.yaml file which contains the workflow.');

    setState(() {
      _nameController.text = widget.workflow?.name ?? '';
      _descriptionController.text = widget.workflow?.description ?? '';
      _webUrlController.text = widget.workflow?.webUrl ?? '';
      _firebaseProjectName.text = widget.workflow?.firebaseProjectName ?? '';
      _firebaseProjectIDController.text =
          widget.workflow?.firebaseProjectId ?? '';

      // Set the timeouts
      _buildAndroidTimeController.text =
          widget.workflow?.androidBuildTimeout.toString() ?? '0';
      _buildIOSTimeController.text =
          widget.workflow?.iOSBuildTimeout.toString() ?? '0';
      _buildLinuxTimeController.text =
          widget.workflow?.linuxBuildTimeout.toString() ?? '0';
      _buildMacOSTimeController.text =
          widget.workflow?.macosBuildTimeout.toString() ?? '0';
      _buildWebTimeController.text =
          widget.workflow?.webBuildTimeout.toString() ?? '0';
      _buildWindowsTimeController.text =
          widget.workflow?.windowsBuildTimeout.toString() ?? '0';

      // Set the build modes & types
      _iOSBuildMode =
          widget.workflow?.iOSBuildMode ?? PlatformBuildModes.release;
      _androidBuildMode =
          widget.workflow?.androidBuildMode ?? PlatformBuildModes.release;
      _webRenderer = widget.workflow?.webRenderer ?? WebRenderers.canvaskit;
      _webBuildMode =
          widget.workflow?.webBuildMode ?? PlatformBuildModes.release;
      _isFirebaseDeployVerified =
          widget.workflow?.isFirebaseDeployVerified ?? false;
      _linuxBuildMode =
          widget.workflow?.linuxBuildMode ?? PlatformBuildModes.release;
      _macOSBuildMode =
          widget.workflow?.macosBuildMode ?? PlatformBuildModes.release;
      _windowsBuildMode =
          widget.workflow?.windowsBuildMode ?? PlatformBuildModes.release;

      // Add the custom workflow actions.
      _customCommands = widget.workflow?.customCommands ?? <String>[];

      if (widget.workflow?.workflowActions == null) {
        _workflowActions = <WorkflowActionModel>[];
      } else {
        _workflowActions = widget.workflow!.workflowActions.map((String e) {
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
    if (widget.workflow != null) {
      _prepareEditSession();
    }

    _beginSaveMonitor();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        WorkflowsState workflowsState = ref.watch(workflowsActionStateNotifier);
        WorkflowsNotifier workflowsNotifier =
            ref.watch(workflowsActionStateNotifier.notifier);

        return WillPopScope(
          onWillPop: () async {
            if (_pubspecFile == null || _pubspecPath.isEmpty) {
              return true;
            }

            await workflowsNotifier.saveWorkflow(
              context,
              showAlerts: true,
              pubspecInfo: _pubspecFile,
              pubspecPath: _pubspecPath,
              addToGitignore: _addToGitIgnore,
              addAllToGitignore: _addAllToGitIgnore,
              template: _workflowTemplate(),
            );

            return true;
          },
          child: DialogTemplate(
            onExit: () async {
              if (_pubspecFile == null || _pubspecPath.isEmpty) {
                Navigator.pop(context);
                return;
              }

              await workflowsNotifier.saveWorkflow(
                context,
                showAlerts: false,
                pubspecInfo: _pubspecFile,
                pubspecPath: _pubspecPath,
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
                  title: widget.workflow != null
                      ? 'Edit Workflow'
                      : 'New Workflow',
                  leading: _interfaceView != _InterfaceView.workflowInfo
                      ? SquareButton(
                          icon: const Icon(Icons.arrow_back_ios_rounded,
                              size: 20),
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
                    if (_pubspecFile == null || _pubspecPath.isEmpty) {
                      Navigator.pop(context);
                      return;
                    }

                    await workflowsNotifier.saveWorkflow(
                      context,
                      showAlerts: false,
                      pubspecInfo: _pubspecFile,
                      pubspecPath: _pubspecPath,
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
                    showLastPage: _showInfoLast || widget.workflow != null,
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
                      setState(() =>
                          _interfaceView = _InterfaceView.workflowActions);
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
                    onActionsUpdate: (_) =>
                        setState(() => _workflowActions = _),
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
                    oniOSBuildModeChanged: (_) =>
                        setState(() => _iOSBuildMode = _),
                    onAndroidBuildTypeChanged: (_) =>
                        setState(() => _androidBuildType = _),
                    onAndroidBuildModeChanged: (_) =>
                        setState(() => _androidBuildMode = _),
                    onBuildWebModeChanged: (_) =>
                        setState(() => _webBuildMode = _),
                    onLinuxBuildModeChanged: (_) =>
                        setState(() => _linuxBuildMode = _),
                    onMacOSBuildModeChanged: (_) =>
                        setState(() => _macOSBuildMode = _),
                    onWindowsBuildModeChanged: (_) =>
                        setState(() => _windowsBuildMode = _),
                    onWebRendererChanged: (_) =>
                        setState(() => _webRenderer = _),
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
                      if (_workflowActions.any((_) =>
                              _.id == WorkflowActionsIds.deployProjectWeb) &&
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
                      await workflowsNotifier.saveWorkflow(
                        context,
                        showAlerts: true,
                        pubspecInfo: _pubspecFile,
                        pubspecPath: _pubspecPath,
                        addToGitignore: _addToGitIgnore,
                        addAllToGitignore: _addAllToGitIgnore,
                        template: _workflowTemplate(true),
                      );

                      bool hasSaved =
                          !workflowsState.loading && !workflowsState.error;

                      if (hasSaved) {
                        // Update the cache with the new changes
                        // await WorkflowSearchUtils.getWorkflowsFromPath(
                        //   cache: await ProjectsNotifier.getCacheSettings(
                        //           (await getApplicationSupportDirectory()).path) ??
                        //       const ProjectCacheSettings(
                        //         projectsPath: null,
                        //         refreshIntervals: null,
                        //         lastProjectReload: null,
                        //         lastWorkflowsReload: null,
                        //       ),
                        //   supportDir: (await getApplicationSupportDirectory()).path,
                        // );

                        if (mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    onSaveAndRun: () async {
                      await workflowsNotifier.saveWorkflow(
                        context,
                        showAlerts: true,
                        pubspecInfo: _pubspecFile,
                        pubspecPath: _pubspecPath,
                        addToGitignore: _addToGitIgnore,
                        addAllToGitignore: _addAllToGitIgnore,
                        template: _workflowTemplate(true),
                      );

                      bool hasSaved =
                          !workflowsState.loading && !workflowsState.error;

                      if (hasSaved) {
                        // Update the cache with the new changes
                        // await WorkflowSearchUtils.getWorkflowsFromPath(
                        //   cache: await ProjectsNotifier.getCacheSettings(
                        //           (await getApplicationSupportDirectory()).path) ??
                        //       const ProjectCacheSettings(
                        //         projectsPath: null,
                        //         refreshIntervals: null,
                        //         lastProjectReload: null,
                        //         lastWorkflowsReload: null,
                        //       ),
                        //   supportDir: (await getApplicationSupportDirectory()).path,
                        // );

                        if (mounted) {
                          Navigator.pop(context);
                        }

                        String? path =
                            (_pubspecPath.split('\\')..removeLast()).join('\\');

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
                            workflow: _workflowTemplate(),
                          ),
                        );
                      }
                    },
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedOpacity(
                    opacity: _saveLocalError ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Builder(
                      builder: (_) {
                        if (_saveLocalError) {
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
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
