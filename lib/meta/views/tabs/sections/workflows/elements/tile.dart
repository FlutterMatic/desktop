// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/shimmer.dart';

class WorkflowInfoTile extends StatefulWidget {
  const WorkflowInfoTile({Key? key}) : super(key: key);

  @override
  _WorkflowInfoTileState createState() => _WorkflowInfoTileState();
}

class _WorkflowInfoTileState extends State<WorkflowInfoTile> {
  @override
  Widget build(BuildContext context) {
    return RoundContainer(
      width: double.infinity,
      height: 100,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Shimmer.fromColors(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Expanded(
                    child: RoundContainer(
                        child: SizedBox.shrink(), width: 200, height: 20),
                  ),
                  VSeparators.xSmall(),
                  const Expanded(
                    child: RoundContainer(
                        child: SizedBox.shrink(), width: 400, height: 20),
                  ),
                  VSeparators.xSmall(),
                  const Expanded(
                    child: RoundContainer(
                        child: SizedBox.shrink(), width: 100, height: 20),
                  ),
                ],
              ),
            ),
          ),
          HSeparators.normal(),
          RectangleButton(
            width: 40,
            height: 40,
            child: const Icon(Icons.play_arrow_rounded,
                color: kGreenColor, size: 22),
            onPressed: () {},
          ),
          HSeparators.small(),
          RectangleButton(
            width: 40,
            height: 40,
            child: const Icon(Icons.edit_rounded, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
