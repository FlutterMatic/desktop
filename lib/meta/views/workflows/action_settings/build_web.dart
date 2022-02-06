// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/app/constants/enum.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/meta/views/workflows/components/assign_timeout.dart';
import 'package:fluttermatic/meta/views/workflows/components/build_mode_selector.dart';
import 'package:fluttermatic/meta/views/workflows/components/expandable_tile.dart';

class BuildWebWorkflowActionConfig extends StatelessWidget {
  final WebRenderers defaultRenderer;
  final Function(WebRenderers renderer) onRendererChanged;
  final PlatformBuildModes defaultBuildMode;
  final Function(PlatformBuildModes mode) onBuildModeChanged;
  final TextEditingController timeoutController;

  const BuildWebWorkflowActionConfig({
    Key? key,
    required this.defaultBuildMode,
    required this.onBuildModeChanged,
    required this.defaultRenderer,
    required this.onRendererChanged,
    required this.timeoutController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConfigureExpandableTile(
      title: 'Build Web',
      subtitle: 'Compile your Flutter app for Web',
      icon: const Icon(Icons.web),
      children: <Widget>[
        const Text('Assign a timeout'),
        VSeparators.normal(),
        SelectActionTimeout(controller: timeoutController),
        VSeparators.normal(),
        const Text('Select the canvas mode'),
        VSeparators.normal(),
        infoWidget(
          context,
          '- HTML: Uses a combination of HTML elements, CSS, Canvas elements, and SVG elements. This renderer has a smaller download size.\n'
          '- CanvasKit: This renderer is fully consistent with Flutter mobile and desktop, has faster performance with higher widget density, but adds about 2MB in download size. (Recommended)',
        ),
        VSeparators.normal(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: selectBuildTypeTile(
                context,
                isSelected: defaultRenderer == WebRenderers.html,
                onSelected: (_) => onRendererChanged(WebRenderers.html),
                text: 'HTML',
              ),
            ),
            HSeparators.normal(),
            Expanded(
              child: selectBuildTypeTile(
                context,
                isSelected: defaultRenderer == WebRenderers.canvaskit,
                onSelected: (_) => onRendererChanged(WebRenderers.canvaskit),
                text: 'CanvasKit',
              ),
            ),
          ],
        ),
        VSeparators.normal(),
        const Text('Select the build mode when creating Web builds'),
        VSeparators.normal(),
        WorkflowActionBuildModeSelector(
          defaultBuildMode: defaultBuildMode,
          onBuildModeChanged: onBuildModeChanged,
        ),
      ],
    );
  }
}
