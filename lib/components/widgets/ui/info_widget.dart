// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/core/libraries/utils.dart';
import 'package:manager/core/libraries/widgets.dart';

Widget infoWidget(BuildContext context, String text) {
  return RoundContainer(
    color: Theme.of(context).isDarkTheme ? Colors.blueGrey.withOpacity(0.2) : AppTheme.lightCardColor,
    radius: 5,
    child: Row(
      children: <Widget>[
        const Icon(Icons.info),
        const SizedBox(width: 8),
        Expanded(child: SelectableText(text)),
      ],
    ),
  );
}
