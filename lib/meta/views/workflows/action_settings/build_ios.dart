// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/meta/views/workflows/components/build_mode_selector.dart';
import 'package:manager/meta/views/workflows/components/expandable_tile.dart';

class BuildIOSWorkflowActionConfig extends StatelessWidget {
  final String defaultBuildMode;
  final Function(String mode) onBuildModeChanged;

  const BuildIOSWorkflowActionConfig({
    Key? key,
    required this.defaultBuildMode,
    required this.onBuildModeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConfigureExpandableTile(
      title: 'Build iOS',
      subtitle: 'Compile your Flutter app for iOS',
      icon: const Icon(Icons.phone_iphone_rounded),
      children: <Widget>[
        const Text('Select the build mode when creating iOS builds'),
        VSeparators.normal(),
        WorkflowActionBuildModeSelector(
          defaultBuildMode: defaultBuildMode,
          onBuildModeChanged: onBuildModeChanged,
        ),
      ],
    );
  }
}
