// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/core/libraries/utils.dart';
import 'package:manager/core/libraries/widgets.dart';

Widget welcomeToolInstalled(BuildContext context, {required String title, required String message}) {
  return RoundContainer(
    color: Theme.of(context).isDarkTheme ? Colors.blueGrey.withOpacity(0.2) : AppTheme.lightCardColor,
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
