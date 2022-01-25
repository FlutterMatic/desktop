// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/core/libraries/constants.dart';
import 'package:fluttermatic/meta/views/workflows/action_settings/build_android.dart';
import 'package:fluttermatic/meta/views/workflows/action_settings/build_ios.dart';
import 'package:fluttermatic/meta/views/workflows/action_settings/build_linux.dart';
import 'package:fluttermatic/meta/views/workflows/action_settings/build_macos.dart';
import 'package:fluttermatic/meta/views/workflows/action_settings/build_web.dart';
import 'package:fluttermatic/meta/views/workflows/action_settings/build_windows.dart';
import 'package:fluttermatic/meta/views/workflows/action_settings/deploy_web.dart';
import 'package:fluttermatic/meta/views/workflows/actions.dart';

class SetProjectWorkflowActionsConfiguration extends StatefulWidget {
  final TextEditingController webUrlController;
  final TextEditingController firebaseProjectName;
  final TextEditingController firebaseProjectIDController;
  final PlatformBuildModes defaultAndroidBuildMode;
  final PlatformBuildModes defaultIOSBuildMode;
  final PlatformBuildModes defaultWebBuildMode;
  final PlatformBuildModes defaultWindowsBuildMode;
  final PlatformBuildModes defaultMacOSBuildMode;
  final PlatformBuildModes defaultLinuxBuildMode;
  final WebRenderers defaultWebRenderer;
  final List<WorkflowActionModel> workflowActions;
  final Function(PlatformBuildModes mode) onAndroidBuildModeChanged;
  final Function(PlatformBuildModes mode) oniOSBuildModeChanged;
  final Function(PlatformBuildModes mode) onBuildWebModeChanged;
  final Function(PlatformBuildModes mode) onWindowsBuildModeChanged;
  final Function(PlatformBuildModes mode) onMacOSBuildModeChanged;
  final Function(PlatformBuildModes mode) onLinuxBuildModeChanged;
  final Function(WebRenderers renderer) onWebRendererChanged;
  final Function(bool isFirebaseValidated) onFirebaseValidatedChanged;
  final bool isFirebaseValidated;
  final Function() onNext;

  const SetProjectWorkflowActionsConfiguration({
    Key? key,
    required this.workflowActions,
    required this.webUrlController,
    required this.firebaseProjectName,
    required this.firebaseProjectIDController,
    required this.onAndroidBuildModeChanged,
    required this.oniOSBuildModeChanged,
    required this.defaultAndroidBuildMode,
    required this.defaultIOSBuildMode,
    required this.onFirebaseValidatedChanged,
    required this.isFirebaseValidated,
    required this.onWebRendererChanged,
    required this.defaultWebRenderer,
    required this.onBuildWebModeChanged,
    required this.defaultWebBuildMode,
    required this.defaultWindowsBuildMode,
    required this.defaultMacOSBuildMode,
    required this.defaultLinuxBuildMode,
    required this.onWindowsBuildModeChanged,
    required this.onMacOSBuildModeChanged,
    required this.onLinuxBuildModeChanged,
    required this.onNext,
  }) : super(key: key);

  @override
  _SetProjectWorkflowActionsConfigurationState createState() =>
      _SetProjectWorkflowActionsConfigurationState();
}

class _SetProjectWorkflowActionsConfigurationState
    extends State<SetProjectWorkflowActionsConfiguration> {
  late PlatformBuildModes _iOSBuildMode = widget.defaultIOSBuildMode;
  late PlatformBuildModes _androidBuildMode = widget.defaultAndroidBuildMode;

  bool get _isDeployWeb => widget.workflowActions
      .where((WorkflowActionModel element) =>
          element.id == WorkflowActionsIds.deployProjectWeb)
      .toList()
      .isNotEmpty;

  bool get _isBuildIOS => widget.workflowActions
      .where((WorkflowActionModel element) =>
          element.id == WorkflowActionsIds.buildProjectForIOS)
      .toList()
      .isNotEmpty;

  bool get _isBuildAndroid => widget.workflowActions
      .where((WorkflowActionModel element) =>
          element.id == WorkflowActionsIds.buildProjectForAndroid)
      .toList()
      .isNotEmpty;

  bool get _isBuildWeb => widget.workflowActions
      .where((WorkflowActionModel element) =>
          element.id == WorkflowActionsIds.buildProjectForWeb)
      .toList()
      .isNotEmpty;

  bool get _isBuildWindows => widget.workflowActions
      .where((WorkflowActionModel element) =>
          element.id == WorkflowActionsIds.buildProjectForWindows)
      .toList()
      .isNotEmpty;

  bool get _isBuildMacOS => widget.workflowActions
      .where((WorkflowActionModel element) =>
          element.id == WorkflowActionsIds.buildProjectForMacOS)
      .toList()
      .isNotEmpty;

  bool get _isBuildLinux => widget.workflowActions
      .where((WorkflowActionModel element) =>
          element.id == WorkflowActionsIds.buildProjectForLinux)
      .toList()
      .isNotEmpty;

  List<bool> get _isBuildActionSelected {
    return <bool>[
      _isDeployWeb,
      _isBuildAndroid,
      _isBuildIOS,
      _isBuildWeb,
      _isBuildWindows,
      _isBuildMacOS,
      _isBuildLinux,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (!_isBuildActionSelected.contains(true))
          Center(
            child: RoundContainer(
              color: Colors.blueGrey.withOpacity(0.1),
              child: Column(
                children: <Widget>[
                  SvgPicture.asset(Assets.done, height: 30),
                  VSeparators.normal(),
                  const Text(
                    'Nothing to configure',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  VSeparators.normal(),
                  const SizedBox(
                    width: 400,
                    child: Text(
                      'You have no additional options to configure your workflow actions, you can move on.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_isDeployWeb)
          DeployWebWorkflowActionConfig(
            firebaseProjectIDController: widget.firebaseProjectIDController,
            firebaseProjectName: widget.firebaseProjectName,
            webUrlController: widget.webUrlController,
            isValidated: widget.isFirebaseValidated,
            onFirebaseValidated: widget.onFirebaseValidatedChanged,
          ),
        if (_isBuildWeb)
          BuildWebWorkflowActionConfig(
            defaultBuildMode: widget.defaultWebBuildMode,
            onBuildModeChanged: widget.onBuildWebModeChanged,
            defaultRenderer: widget.defaultWebRenderer,
            onRendererChanged: widget.onWebRendererChanged,
          ),
        if (_isBuildAndroid)
          BuildAndroidWorkflowActionConfig(
            defaultBuildMode: _androidBuildMode,
            onBuildModeChanged: (PlatformBuildModes mode) {
              widget.onAndroidBuildModeChanged(mode);
              setState(() => _androidBuildMode = mode);
            },
          ),
        if (_isBuildIOS)
          BuildIOSWorkflowActionConfig(
            defaultBuildMode: _iOSBuildMode,
            onBuildModeChanged: (PlatformBuildModes mode) {
              widget.oniOSBuildModeChanged(mode);
              setState(() => _iOSBuildMode = mode);
            },
          ),
        if (_isBuildWindows)
          BuildWindowsWorkflowActionConfig(
            onBuildModeChanged: widget.onWindowsBuildModeChanged,
            defaultBuildMode: widget.defaultWindowsBuildMode,
          ),
        if (_isBuildMacOS)
          BuildMacOSWorkflowActionConfig(
            onBuildModeChanged: widget.onMacOSBuildModeChanged,
            defaultBuildMode: widget.defaultMacOSBuildMode,
          ),
        if (_isBuildLinux)
          BuildLinuxWorkflowActionConfig(
            onBuildModeChanged: widget.onLinuxBuildModeChanged,
            defaultBuildMode: widget.defaultLinuxBuildMode,
          ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 15),
            child: RectangleButton(
              width: 100,
              child: const Text('Next'),
              onPressed: widget.onNext,
            ),
          ),
        ),
      ],
    );
  }
}
