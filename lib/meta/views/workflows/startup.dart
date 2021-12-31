// 🐦 Flutter imports:
import 'dart:io';

import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/components/widgets/buttons/rectangle_button.dart';
import 'package:manager/components/widgets/buttons/square_button.dart';
import 'package:manager/components/widgets/ui/dialog_template.dart';
import 'package:manager/components/widgets/ui/snackbar_tile.dart';
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

  _InterfaceView _interfaceView = _InterfaceView.workflowInfo;

  // Actions Config
  String _iOSBuildMode = 'Release';
  String _androidBuildMode = 'Release';
  bool _isFirebaseDeployVerified = false;
  String _defaultWebRenderer = 'CanvasKit';
  String _defaultWebBuildMode = 'Release';

  // Utils
  bool _showInfoLast = false;

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
      List<String> _pubspec =
          await File.fromUri(Uri.file(widget.pubspecPath!, windows: true))
              .readAsLines();

      _pubspecFile = extractPubspec(_pubspec);
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
    super.initState();
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
