import 'package:flutter/material.dart';

class BulletPoint extends StatelessWidget {
  final String text;
  final double level;

  const BulletPoint(this.text, [this.level = 1, Key? key]) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            left: (15 * level),
          ),
          child: Container(
            height: 15,
            width: 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blueGrey, width: 2),
              color: level > 1 ? Colors.transparent : Colors.blueGrey,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(text),
        ),
      ],
    );
  }
}
