// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/ui/round_container.dart';

Widget currentDirectoryTile() {
  return RoundContainer(
    color: Colors.blueGrey.withOpacity(0.2),
    radius: 5,
    width: double.infinity,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Current Directory',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        VSeparators.small(),
        // TODO: Show the project directory in the current directory tile.
        const Text('projDir'),
      ],
    ),
  );
}
