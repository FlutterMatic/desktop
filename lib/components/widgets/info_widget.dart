import 'package:flutter/material.dart';
import 'package:flutter_installer/components/widgets/round_container.dart';

Widget infoWidget(String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 10),
    child: RoundContainer(
      color: Colors.blueGrey.withOpacity(0.2),
      radius: 5,
      child: Row(
        children: <Widget>[
          const Icon(Icons.info),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    ),
  );
}
