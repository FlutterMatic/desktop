import 'package:flutter/material.dart';
import 'package:flutter_installer/components/title_section.dart';

Widget projects() {
  return SizedBox(
    width: 450,
    child: Column(
      children: <Widget>[
        titleSection('Projects', const Icon(Icons.add_rounded), () {},
            'New Flutter Project'),
      ],
    ),
  );
}

// Widget _projectTile() {
//   return;
// }