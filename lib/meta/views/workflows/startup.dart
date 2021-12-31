// 🐦 Flutter imports:
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/components/widgets/buttons/rectangle_button.dart';
import 'package:manager/components/widgets/buttons/square_button.dart';
import 'package:manager/components/widgets/ui/dialog_template.dart';
import 'package:manager/components/widgets/ui/snackbar_tile.dart';
import 'package:manager/components/widgets/ui/spinner.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/core/libraries/utils.dart';
import 'package:manager/meta/utils/extract_pubspec.dart';
import 'package:manager/meta/views/workflows/actions.dart';
import 'package:manager/meta/views/workflows/sections/actions.dart';
import 'package:manager/meta/views/workflows/sections/configure_actions.dart';
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
  String _iOSBuildMode = 'Release';
  String _androidBuildMode = 'Release';
  bool _isFirebaseDeployVerified = false;
  String _defaultWebRenderer = 'CanvasKit';
  String _defaultWebBuildMode = 'Release';

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
      Map<String, dynamic> _pendingChanges = <String, dynamic>{
        'name': _nameController.text,
        'description': _descriptionController.text,
        'web_url': _webUrlController.text,
        'firebase_project_name': _firebaseProjectName.text,
        'firebase_project_id': _firebaseProjectIDController.text,
        'ios_build_mode': _iOSBuildMode,
        'android_build_mode': _androidBuildMode,
        'is_firebase_deploy_verified': _isFirebaseDeployVerified,
        'default_web_renderer': _defaultWebRenderer,
        'default_web_build_mode': _defaultWebBuildMode,
        'workflow_actions':
            _workflowActions.map((WorkflowActionModel e) => e.id).join(','),
      };

      // If the user has not made any changes, no need to save anything.
      if (_pendingChanges == _lastSavedContent || _pubspecFile == null) {
        // Without this line, app crashes.
        await Future<void>.delayed(_syncIntervals);
        continue;
      }

      setState(() => _isSavingLocally = true);

      Isolate _isolate = await Isolate.spawn(_saveFormInPath, <dynamic>[
        _saveLocallyPort.sendPort,
        _pubspecFile?.pathToPubspec ?? widget.pubspecPath,
        _pendingChanges,
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

  void _confirmCancel() {
    showDialog(
      context: context,
      builder: (_) => DialogTemplate(
        width: 450,
        child: Column(
          children: <Widget>[
            const Text('Are you sure?',
                style: TextStyle(fontWeight: FontWeight.bold)),
            VSeparators.normal(),
            const Text(
              'If you exit then your workflow won\'t be saved. Complete setting up your workflow to avoid losing your work so far.',
              textAlign: TextAlign.center,
            ),
            VSeparators.large(),
            Row(
              children: <Widget>[
                Expanded(
                  child: RectangleButton(
                    child: const Text('Cancel Workflow'),
                    hoverColor: AppTheme.errorColor,
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ),
                ),
                HSeparators.normal(),
                Expanded(
                  child: RectangleButton(
                    child: const Text('Back'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
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
        ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
          context,
          'Couldn\'t read pubspec.yaml file. Invalid permissions set. Please try again.',
          type: SnackBarType.error,
          revert: true,
        ));
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
    return DialogTemplate(
      onExit: _confirmCancel,
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
            onClose: _confirmCancel,
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    snackBarTile(
                      context,
                      'Please select your pubspec.yaml file to continue.',
                      type: SnackBarType.error,
                      revert: true,
                    ),
                  );
                  return;
                }
                setState(() => _interfaceView = _InterfaceView.workflowActions);
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
                      revert: true,
                    ),
                  );
                  return;
                }
                setState(() => _interfaceView = _InterfaceView.actionsReorder);
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
              oniOSBuildModeChanged: (String mode) =>
                  setState(() => _iOSBuildMode = mode),
              defaultAndroidBuildMode: _androidBuildMode,
              onAndroidBuildModeChanged: (String mode) =>
                  setState(() => _androidBuildMode = mode),
              isFirebaseValidated: _isFirebaseDeployVerified,
              onFirebaseValidatedChanged: (bool isFirebaseValidated) =>
                  setState(
                      () => _isFirebaseDeployVerified = isFirebaseValidated),
              defaultWebBuildMode: _defaultWebBuildMode,
              defaultWebRenderer: _defaultWebRenderer,
              onBuildWebModeChanged: (String mode) =>
                  setState(() => _defaultWebBuildMode = mode),
              onWebRendererChanged: (String renderer) =>
                  setState(() => _defaultWebRenderer = renderer),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: Opacity(
              opacity:
                  (_saveLocalError && !_isSavingLocally || _isSavingLocally)
                      ? 1
                      : 0,
              child: _isSavingLocally
                  ? Tooltip(
                      message:
                          'Saving your workflow data locally so you don\'t lose your work.',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Spinner(size: 10, thickness: 1),
                          HSeparators.small(),
                          const Text(
                            'Syncing workflow...',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : _saveLocalError
                      ? Tooltip(
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
                        )
                      : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

enum _InterfaceView {
  workflowInfo,
  workflowActions,
  actionsReorder,
  configureActions,
}

Future<void> _saveFormInPath(List<dynamic> data) async {
  // The opened port we can communicate with.
  SendPort _port = data[0];
  Map<String, dynamic> _data = data[2];

  try {
    String? _dirPath = data[1];

    if (_dirPath == null || _dirPath.isEmpty || _data.isEmpty) {
      _port.send(_data);
      return;
    }

    _dirPath = (_dirPath.toString().split('\\')..removeLast()).join('\\');

    await File.fromUri(Uri.file(_dirPath + '\\fmatic_workflows.json'))
        .writeAsString(jsonEncode(_data))
        .timeout(const Duration(seconds: 3));

    _port.send(_data);
  } catch (_, s) {
    await logger.file(LogTypeTag.error, 'Couldn\'t sync workflow settings.',
        stackTraces: s);
    _port.send(<dynamic>[]);
  }
}
