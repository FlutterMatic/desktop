import 'package:flutter/material.dart';
import 'package:flutter_installer/components/widgets/ui/round_container.dart';
import 'package:flutter_installer/utils/constants.dart';

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
        const SizedBox(height: 10),
        Text(projDir!),
      ],
    ),
  );
}