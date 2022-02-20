// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/app/constants/enum.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/meta/views/workflows/action_settings/build_android.dart';
import 'package:fluttermatic/meta/views/workflows/action_settings/build_ios.dart';
import 'package:fluttermatic/meta/views/workflows/action_settings/build_linux.dart';
import 'package:fluttermatic/meta/views/workflows/action_settings/build_macos.dart';
import 'package:fluttermatic/meta/views/workflows/action_settings/build_web.dart';
import 'package:fluttermatic/meta/views/workflows/action_settings/build_windows.dart';
import 'package:fluttermatic/meta/views/workflows/action_settings/custom_commands.dart';
import 'package:fluttermatic/meta/views/workflows/action_settings/deploy_web.dart';
import 'package:fluttermatic/meta/views/workflows/actions.dart';

class SetProjectWorkflowActionsConfiguration extends StatefulWidget {
  // Input Controllers
  final TextEditingController webUrlController;
  final TextEditingController firebaseProjectName;
  final TextEditingController firebaseProjectIDController;

  // ... Timeout Controllers
  final TextEditingController buildAndroidTimeController;
  final TextEditingController buildIOSTimeController;
  final TextEditingController buildWindowsTimeController;
  final TextEditingController buildLinuxTimeController;
  final TextEditingController buildMacOSTimeController;
  final TextEditingController buildWebTimeController;

  // Build Modes & Types
  final AndroidBuildType androidBuildType;
  final PlatformBuildModes defaultAndroidBuildMode;
  final PlatformBuildModes defaultIOSBuildMode;
  final PlatformBuildModes defaultWebBuildMode;
  final PlatformBuildModes defaultWindowsBuildMode;
  final PlatformBuildModes defaultMacOSBuildMode;
  final PlatformBuildModes defaultLinuxBuildMode;
  final WebRenderers defaultWebRenderer;

  // Trigger Callbacks
  final Function(AndroidBuildType type) onAndroidBuildTypeChanged;
  final Function(PlatformBuildModes mode) onAndroidBuildModeChanged;
  final Function(PlatformBuildModes mode) oniOSBuildModeChanged;
  final Function(PlatformBuildModes mode) onBuildWebModeChanged;
  final Function(PlatformBuildModes mode) onWindowsBuildModeChanged;
  final Function(PlatformBuildModes mode) onMacOSBuildModeChanged;
  final Function(PlatformBuildModes mode) onLinuxBuildModeChanged;
  final Function(WebRenderers renderer) onWebRendererChanged;
  final Function(List<String> commands) onCustomCommandsChanged;

  // Workflow Actions
  final List<WorkflowActionModel> workflowActions;

  // Custom Commands
  final List<String> customCommands;

  // Utils
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
    required this.androidBuildType,
    required this.onAndroidBuildTypeChanged,
    required this.buildAndroidTimeController,
    required this.buildIOSTimeController,
    required this.buildWindowsTimeController,
    required this.buildLinuxTimeController,
    required this.buildMacOSTimeController,
    required this.buildWebTimeController,
    required this.onNext,
    required this.onCustomCommandsChanged,
    required this.customCommands,
  }) : super(key: key);

  @override
  _SetProjectWorkflowActionsConfigurationState createState() =>
      _SetProjectWorkflowActionsConfigurationState();
}

class _SetProjectWorkflowActionsConfigurationState
    extends State<SetProjectWorkflowActionsConfiguration> {
  bool get _isDeployWeb => widget.workflowActions
      .where((WorkflowActionModel _) =>
          _.id == WorkflowActionsIds.deployProjectWeb)
      .toList()
      .isNotEmpty;

  bool get _isBuildIOS => widget.workflowActions
      .where((WorkflowActionModel _) =>
          _.id == WorkflowActionsIds.buildProjectForIOS)
      .toList()
      .isNotEmpty;

  bool get _isBuildAndroid => widget.workflowActions
      .where((WorkflowActionModel _) =>
          _.id == WorkflowActionsIds.buildProjectForAndroid)
      .toList()
      .isNotEmpty;

  bool get _isBuildWeb => widget.workflowActions
      .where((WorkflowActionModel _) =>
          _.id == WorkflowActionsIds.buildProjectForWeb)
      .toList()
      .isNotEmpty;

  bool get _isBuildWindows => widget.workflowActions
      .where((WorkflowActionModel _) =>
          _.id == WorkflowActionsIds.buildProjectForWindows)
      .toList()
      .isNotEmpty;

  bool get _isBuildMacOS => widget.workflowActions
      .where((WorkflowActionModel _) =>
          _.id == WorkflowActionsIds.buildProjectForMacOS)
      .toList()
      .isNotEmpty;

  bool get _isBuildLinux => widget.workflowActions
      .where((WorkflowActionModel _) =>
          _.id == WorkflowActionsIds.buildProjectForLinux)
      .toList()
      .isNotEmpty;

  bool get _isCustomCommands => widget.workflowActions
      .where((WorkflowActionModel _) =>
          _.id == WorkflowActionsIds.runCustomCommands)
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
      _isCustomCommands,
    ];
  }

  @override
  Widget build(BuildContext context) {
    List<_TabObject> _tabs = <_TabObject>[
      if (_isDeployWeb)
        _TabObject(
          name: 'Deploy Web',
          content: DeployWebWorkflowActionConfig(
            firebaseProjectIDController: widget.firebaseProjectIDController,
            firebaseProjectName: widget.firebaseProjectName,
            webUrlController: widget.webUrlController,
            isValidated: widget.isFirebaseValidated,
            onFirebaseValidated: widget.onFirebaseValidatedChanged,
          ),
        ),
      if (_isBuildWeb)
        _TabObject(
          name: 'Build Web',
          content: BuildWebWorkflowActionConfig(
            defaultBuildMode: widget.defaultWebBuildMode,
            onBuildModeChanged: widget.onBuildWebModeChanged,
            defaultRenderer: widget.defaultWebRenderer,
            onRendererChanged: widget.onWebRendererChanged,
            timeoutController: widget.buildWebTimeController,
          ),
        ),
      if (_isBuildAndroid)
        _TabObject(
          name: 'Build Android',
          content: BuildAndroidWorkflowActionConfig(
            defaultBuildMode: widget.defaultAndroidBuildMode,
            onBuildModeChanged: widget.onAndroidBuildModeChanged,
            buildType: widget.androidBuildType,
            onBuildTypeChanged: widget.onAndroidBuildTypeChanged,
            timeoutController: widget.buildAndroidTimeController,
          ),
        ),
      if (_isBuildIOS)
        _TabObject(
          name: 'Build iOS',
          content: BuildIOSWorkflowActionConfig(
            defaultBuildMode: widget.defaultIOSBuildMode,
            onBuildModeChanged: widget.oniOSBuildModeChanged,
            timeoutController: widget.buildIOSTimeController,
          ),
        ),
      if (_isBuildWindows)
        _TabObject(
          name: 'Build Windows',
          content: BuildWindowsWorkflowActionConfig(
            timeoutController: widget.buildWindowsTimeController,
            onBuildModeChanged: widget.onWindowsBuildModeChanged,
            defaultBuildMode: widget.defaultWindowsBuildMode,
          ),
        ),
      if (_isBuildMacOS)
        _TabObject(
          name: 'Build macOS',
          content: BuildMacOSWorkflowActionConfig(
            onBuildModeChanged: widget.onMacOSBuildModeChanged,
            defaultBuildMode: widget.defaultMacOSBuildMode,
            timeoutController: widget.buildMacOSTimeController,
          ),
        ),
      if (_isBuildLinux)
        _TabObject(
          name: 'Build Linux',
          content: BuildLinuxWorkflowActionConfig(
            onBuildModeChanged: widget.onLinuxBuildModeChanged,
            defaultBuildMode: widget.defaultLinuxBuildMode,
            timeoutController: widget.buildLinuxTimeController,
          ),
        ),
      if (_isCustomCommands)
        _TabObject(
          name: 'Custom Commands',
          content: CustomCommandsWorkflowActionsConfig(
            commands: widget.customCommands,
            onCommandsChanged: widget.onCustomCommandsChanged,
          ),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Builder(
          builder: (_) {
            if (_tabs.length == 1) {
              return _tabs.first.content;
            } else if (!_isBuildActionSelected.contains(true)) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: <Widget>[
                      SvgPicture.asset(Assets.done, height: 30),
                      VSeparators.normal(),
                      const Text(
                        'Nothing to configure',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      VSeparators.normal(),
                      const SizedBox(
                        width: 400,
                        child: Text(
                          'You have no additional options to configure your workflow\nactions, you can move on.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 450),
                child: DefaultTabController(
                  length: _tabs.length,
                  child: Column(
                    children: <Widget>[
                      TabBar(
                          tabs: _tabs
                              .map(
                                (_) => Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Tooltip(
                                    message: _.name,
                                    waitDuration:
                                        const Duration(milliseconds: 300),
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 3),
                                      child: Text(_.name,
                                          maxLines: 1,
                                          softWrap: true,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ),
                                ),
                              )
                              .toList()),
                      VSeparators.small(),
                      Expanded(
                        child: TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: _tabs
                              .map((_) =>
                                  SingleChildScrollView(child: _.content))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
        VSeparators.small(),
        Align(
          alignment: Alignment.centerRight,
          child: RectangleButton(
            width: 100,
            child: const Text('Next'),
            onPressed: widget.onNext,
          ),
        ),
      ],
    );
  }
}

class _TabObject {
  final String name;
  final Widget content;

  const _TabObject({
    required this.name,
    required this.content,
  });
}
