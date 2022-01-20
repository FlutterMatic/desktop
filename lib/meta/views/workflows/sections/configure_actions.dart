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
import 'package:fluttermatic/meta/views/workflows/action_settings/build_web.dart';
import 'package:fluttermatic/meta/views/workflows/action_settings/deploy_web.dart';
import 'package:fluttermatic/meta/views/workflows/actions.dart';

class SetProjectWorkflowActionsConfiguration extends StatefulWidget {
  final TextEditingController webUrlController;
  final TextEditingController firebaseProjectName;
  final TextEditingController firebaseProjectIDController;
  final List<WorkflowActionModel> workflowActions;
  final Function(PlatformBuildModes mode) onAndroidBuildModeChanged;
  final Function(PlatformBuildModes mode) oniOSBuildModeChanged;
  final PlatformBuildModes defaultAndroidBuildMode;
  final PlatformBuildModes defaultIOSBuildMode;
  final Function(bool isFirebaseValidated) onFirebaseValidatedChanged;
  final bool isFirebaseValidated;
  final Function(WebRenderers renderer) onWebRendererChanged;
  final WebRenderers defaultWebRenderer;
  final Function(PlatformBuildModes mode) onBuildWebModeChanged;
  final PlatformBuildModes defaultWebBuildMode;
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

  bool get isDeployWeb => widget.workflowActions
      .where((WorkflowActionModel element) =>
          element.id == WorkflowActionsIds.deployProjectWeb)
      .toList()
      .isNotEmpty;

  bool get isBuildIOS => widget.workflowActions
      .where((WorkflowActionModel element) =>
          element.id == WorkflowActionsIds.buildProjectForIOS)
      .toList()
      .isNotEmpty;

  bool get isBuildAndroid => widget.workflowActions
      .where((WorkflowActionModel element) =>
          element.id == WorkflowActionsIds.buildProjectForAndroid)
      .toList()
      .isNotEmpty;

  bool get isBuildWeb => widget.workflowActions
      .where((WorkflowActionModel element) =>
          element.id == WorkflowActionsIds.buildProjectForWeb)
      .toList()
      .isNotEmpty;

  List<bool> get isBuildActionSelected {
    return <bool>[
      isDeployWeb,
      isBuildAndroid,
      isBuildIOS,
      isBuildWeb,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (!isBuildActionSelected.contains(true))
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
        if (isDeployWeb)
          DeployWebWorkflowActionConfig(
            firebaseProjectIDController: widget.firebaseProjectIDController,
            firebaseProjectName: widget.firebaseProjectName,
            webUrlController: widget.webUrlController,
            isValidated: widget.isFirebaseValidated,
            onFirebaseValidated: widget.onFirebaseValidatedChanged,
          ),
        if (isBuildWeb)
          BuildWebWorkflowActionConfig(
            defaultBuildMode: widget.defaultWebBuildMode,
            onBuildModeChanged: widget.onBuildWebModeChanged,
            defaultRenderer: widget.defaultWebRenderer,
            onRendererChanged: widget.onWebRendererChanged,
          ),
        if (isBuildAndroid)
          BuildAndroidWorkflowActionConfig(
            defaultBuildMode: _androidBuildMode,
            onBuildModeChanged: (PlatformBuildModes mode) {
              widget.onAndroidBuildModeChanged(mode);
              setState(() => _androidBuildMode = mode);
            },
          ),
        if (isBuildIOS)
          BuildIOSWorkflowActionConfig(
            defaultBuildMode: _iOSBuildMode,
            onBuildModeChanged: (PlatformBuildModes mode) {
              widget.oniOSBuildModeChanged(mode);
              setState(() => _iOSBuildMode = mode);
            },
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
