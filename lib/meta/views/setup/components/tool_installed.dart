// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';

Widget setUpToolInstalled(
  BuildContext context, {
  required String title,
  required String message,
}) {
  return RoundContainer(
    padding: const EdgeInsets.all(15),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: const TextStyle(fontSize: 16)),
              VSeparators.xSmall(),
              Text(message, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
        HSeparators.normal(),
        const Icon(Icons.check_circle_outline_rounded, color: kGreenColor),
      ],
    ),
  );
}
