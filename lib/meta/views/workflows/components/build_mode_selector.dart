// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/app/constants/enum.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';

class WorkflowActionBuildModeSelector extends StatelessWidget {
  final PlatformBuildModes defaultBuildMode;
  final Function(PlatformBuildModes mode) onBuildModeChanged;

  const WorkflowActionBuildModeSelector({
    Key? key,
    required this.defaultBuildMode,
    required this.onBuildModeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        infoWidget(
          context,
          '- Release: Builds the app for release.\n'
          '- Debug: Builds the app for debug.\n'
          '- Profile: Builds the app for profile.',
        ),
        VSeparators.normal(),
        Row(
          children: <Widget>[
            Expanded(
              child: selectBuildTypeTile(
                context,
                text: 'Debug',
                onSelected: (_) => onBuildModeChanged(PlatformBuildModes.debug),
                isSelected: defaultBuildMode == PlatformBuildModes.debug,
              ),
            ),
            HSeparators.normal(),
            Expanded(
              child: selectBuildTypeTile(
                context,
                text: 'Profile',
                onSelected: (_) =>
                    onBuildModeChanged(PlatformBuildModes.profile),
                isSelected: defaultBuildMode == PlatformBuildModes.profile,
              ),
            ),
            HSeparators.normal(),
            Expanded(
              child: selectBuildTypeTile(
                context,
                text: 'Release',
                onSelected: (_) =>
                    onBuildModeChanged(PlatformBuildModes.release),
                isSelected: defaultBuildMode == PlatformBuildModes.release,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Widget selectBuildTypeTile(
  BuildContext context, {
  required String text,
  required Function(String) onSelected,
  required bool isSelected,
}) {
  return RectangleButton(
    color: Colors.blueGrey.withOpacity(0.2),
    disableColor: Colors.blueGrey.withOpacity(0.2),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    width: double.infinity,
    child: Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (isSelected)
            SvgPicture.asset(Assets.done, height: 20, color: kGreenColor)
          else
            const RoundContainer(
              width: 20,
              height: 20,
              radius: 50,
              color: Colors.transparent,
              borderColor: kGreenColor,
              child: SizedBox.shrink(),
            ),
          HSeparators.small(),
          Text(
            text,
            style:
                TextStyle(color: Theme.of(context).textTheme.headline1?.color),
          ),
        ],
      ),
    ),
    onPressed: () => onSelected(text),
    disable: isSelected,
  );
}
