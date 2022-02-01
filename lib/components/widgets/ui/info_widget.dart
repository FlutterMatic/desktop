// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/components/widgets/ui/round_container.dart';

Widget infoWidget(BuildContext context, String text) {
  return RoundContainer(
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
