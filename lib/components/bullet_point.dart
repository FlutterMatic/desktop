import 'package:flutter/material.dart';

class BulletPoint extends StatelessWidget {
  final String text;
  final double? level;

  BulletPoint(this.text, [this.level = 0]);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(left: (15 * level!)),
          child: Container(
            height: 15,
            width: 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blueGrey, width: 2),
              color: level != 0 ? Colors.transparent : Colors.blueGrey,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(child: Text(text)),
      ],
    );
  }
}
