// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/meta/views/workflows/components/build_mode_selector.dart';
import 'package:manager/meta/views/workflows/components/expandable_tile.dart';

class BuildAndroidWorkflowActionConfig extends StatelessWidget {
  final String defaultBuildMode;
  final Function(String mode) onBuildModeChanged;

  const BuildAndroidWorkflowActionConfig({
    Key? key,
    required this.defaultBuildMode,
    required this.onBuildModeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConfigureExpandableTile(
      title: 'Build Android',
      subtitle: 'Compile your Flutter app for Android',
      icon: const Icon(Icons.phone_android_rounded),
      children: <Widget>[
        const Text('Select the build mode when creating Android builds'),
        VSeparators.normal(),
        WorkflowActionBuildModeSelector(
          defaultBuildMode: defaultBuildMode,
          onBuildModeChanged: onBuildModeChanged,
        ),
      ],
    );
  }
}
