// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';

Widget infoWidget(BuildContext context, String text) {
  return RoundContainer(
    color: Theme.of(context).isDarkTheme
        ? Colors.blueGrey.withOpacity(0.2)
        : AppTheme.lightCardColor,
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
