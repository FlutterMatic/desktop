// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/enum.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/meta/views/workflows/components/assign_timeout.dart';
import 'package:fluttermatic/meta/views/workflows/components/build_mode_selector.dart';

class BuildAndroidWorkflowActionConfig extends StatelessWidget {
  final PlatformBuildModes defaultBuildMode;
  final Function(PlatformBuildModes mode) onBuildModeChanged;
  final AndroidBuildType buildType;
  final Function(AndroidBuildType type) onBuildTypeChanged;
  final TextEditingController timeoutController;

  const BuildAndroidWorkflowActionConfig({
    Key? key,
    required this.defaultBuildMode,
    required this.onBuildModeChanged,
    required this.onBuildTypeChanged,
    required this.buildType,
    required this.timeoutController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Assign a timeout'),
        VSeparators.normal(),
        SelectActionTimeout(controller: timeoutController),
        VSeparators.normal(),
        const Text('Select the build type'),
        VSeparators.normal(),
        infoWidget(
          context,
          '- appBundle (Recommended)\n'
          '- apk',
        ),
        VSeparators.normal(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: selectBuildTypeTile(
                context,
                isSelected: buildType == AndroidBuildType.appBundle,
                onSelected: (_) =>
                    onBuildTypeChanged(AndroidBuildType.appBundle),
                text: 'App Bundle',
              ),
            ),
            HSeparators.normal(),
            Expanded(
              child: selectBuildTypeTile(
                context,
                isSelected: buildType == AndroidBuildType.apk,
                onSelected: (_) => onBuildTypeChanged(AndroidBuildType.apk),
                text: 'APK',
              ),
            ),
          ],
        ),
        VSeparators.normal(),
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
