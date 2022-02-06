// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/app/constants/enum.dart';
import 'package:fluttermatic/meta/views/workflows/components/assign_timeout.dart';
import 'package:fluttermatic/meta/views/workflows/components/build_mode_selector.dart';
import 'package:fluttermatic/meta/views/workflows/components/expandable_tile.dart';

class BuildWindowsWorkflowActionConfig extends StatelessWidget {
  final PlatformBuildModes defaultBuildMode;
  final Function(PlatformBuildModes mode) onBuildModeChanged;
  final TextEditingController timeoutController;

  const BuildWindowsWorkflowActionConfig({
    Key? key,
    required this.defaultBuildMode,
    required this.onBuildModeChanged,
    required this.timeoutController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConfigureExpandableTile(
      title: 'Build Windows',
      subtitle: 'Compile your Flutter app for Windows',
      icon: const Icon(Icons.window_rounded),
      children: <Widget>[
        const Text('Assign a timeout'),
        VSeparators.normal(),
        SelectActionTimeout(controller: timeoutController),
        VSeparators.normal(),
        const Text('Select the build mode when creating Windows builds'),
        VSeparators.normal(),
        WorkflowActionBuildModeSelector(
          defaultBuildMode: defaultBuildMode,
          onBuildModeChanged: onBuildModeChanged,
        ),
      ],
    );
  }
}
