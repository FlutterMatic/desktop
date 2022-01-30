import 'package:flutter/material.dart';
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';

class ComingSoonTile extends StatelessWidget {
  const ComingSoonTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RoundContainer(
      padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
      color: kGreenColor.withOpacity(0.1),
      radius: 50,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const RoundContainer(
            height: 5,
            width: 5,
            color: kGreenColor,
            child: SizedBox.shrink(),
          ),
          HSeparators.xSmall(),
          const Text('Coming Soon', style: TextStyle(color: kGreenColor)),
        ],
      ),
    );
  }
}
