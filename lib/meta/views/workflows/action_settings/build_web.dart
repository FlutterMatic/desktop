// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/components/widgets/ui/info_widget.dart';
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/meta/views/workflows/components/build_mode_selector.dart';
import 'package:manager/meta/views/workflows/components/expandable_tile.dart';

class BuildWebWorkflowActionConfig extends StatefulWidget {
  final WebRenderers defaultRenderer;
  final Function(WebRenderers renderer) onRendererChanged;
  final PlatformBuildModes defaultBuildMode;
  final Function(PlatformBuildModes mode) onBuildModeChanged;

  const BuildWebWorkflowActionConfig({
    Key? key,
    required this.defaultBuildMode,
    required this.onBuildModeChanged,
    required this.defaultRenderer,
    required this.onRendererChanged,
  }) : super(key: key);

  @override
  _BuildWebWorkflowActionConfigState createState() =>
      _BuildWebWorkflowActionConfigState();
}

class _BuildWebWorkflowActionConfigState
    extends State<BuildWebWorkflowActionConfig> {
  @override
  Widget build(BuildContext context) {
    return ConfigureExpandableTile(
      title: 'Build Web',
      subtitle: 'Compile your Flutter app for Web',
      icon: const Icon(Icons.web),
      children: <Widget>[
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
                isSelected: widget.defaultRenderer == WebRenderers.html,
                onSelected: (_) => widget.onRendererChanged(WebRenderers.html),
                text: 'HTML',
              ),
            ),
            HSeparators.normal(),
            Expanded(
              child: selectBuildTypeTile(
                context,
                isSelected: widget.defaultRenderer == WebRenderers.canvaskit,
                onSelected: (_) =>
                    widget.onRendererChanged(WebRenderers.canvaskit),
                text: 'CanvasKit',
              ),
            ),
          ],
        ),
        VSeparators.normal(),
        const Text('Select the build mode when creating Web builds'),
        VSeparators.normal(),
        WorkflowActionBuildModeSelector(
          defaultBuildMode: widget.defaultBuildMode,
          onBuildModeChanged: widget.onBuildModeChanged,
        ),
      ],
    );
  }
}
