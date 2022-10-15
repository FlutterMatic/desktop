// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/components/widgets/ui/round_container.dart';

/// I KNOW!!! It's a stupid idea. 😭 Just deal with it. Keep it this way.
/// (It's fun though), I am sorry.
class StressReliefWidget extends StatelessWidget {
  const StressReliefWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Tooltip(
          message: 'AHH',
          child: ClipRRect(
            borderRadius: BorderRadius.horizontal(left: Radius.circular(5)),
            child: RoundContainer(
              radius: 0,
              color: Colors.white,
              child: SizedBox.shrink(),
            ),
          ),
        ),
        ...List<int>.generate(25, (int i) => i % 2 == 0 ? 1 : 0).map((int e) {
          return Expanded(
            child: Tooltip(
              message: e == 0 ? 'AHH' : 'HELP',
              child: RoundContainer(
                radius: 0,
                color: e == 0 ? Colors.white : Colors.black,
                child: const SizedBox.shrink(),
              ),
            ),
          );
        }).toList(),
        const Tooltip(
          message: 'AHH',
          child: ClipRRect(
            borderRadius: BorderRadius.horizontal(right: Radius.circular(5)),
            child: RoundContainer(
              radius: 0,
              color: Colors.white,
              child: SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}
