// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/core/libraries/widgets.dart';

class WorkflowActionBuildModeSelector extends StatelessWidget {
  final String defaultBuildMode;
  final Function(String mode) onBuildModeChanged;

  const WorkflowActionBuildModeSelector(
      {Key? key,
      required this.defaultBuildMode,
      required this.onBuildModeChanged})
      : super(key: key);

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
                onSelected: onBuildModeChanged,
                isSelected: defaultBuildMode == 'Debug',
              ),
            ),
            HSeparators.normal(),
            Expanded(
              child: selectBuildTypeTile(
                context,
                text: 'Profile',
                onSelected: onBuildModeChanged,
                isSelected: defaultBuildMode == 'Profile',
              ),
            ),
            HSeparators.normal(),
            Expanded(
              child: selectBuildTypeTile(
                context,
                text: 'Release',
                onSelected: onBuildModeChanged,
                isSelected: defaultBuildMode == 'Release',
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