// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/app/constants/enum.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/meta/views/workflows/components/build_mode_selector.dart';
import 'package:fluttermatic/meta/views/workflows/components/expandable_tile.dart';

class BuildAndroidWorkflowActionConfig extends StatelessWidget {
  final PlatformBuildModes defaultBuildMode;
  final Function(PlatformBuildModes mode) onBuildModeChanged;
  final AndroidBuildType buildType;
  final Function(AndroidBuildType type) onBuildTypeChanged;

  const BuildAndroidWorkflowActionConfig({
    Key? key,
    required this.defaultBuildMode,
    required this.onBuildModeChanged,
    required this.onBuildTypeChanged,
    required this.buildType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConfigureExpandableTile(
      title: 'Build Android',
      subtitle: 'Compile your Flutter app for Android',
      icon: const Icon(Icons.phone_android_rounded),
      children: <Widget>[
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
