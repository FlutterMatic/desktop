import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CheckBoxElement extends StatelessWidget {
  final bool value;
  final bool disable;
  final Function(bool?) onChanged;
  final String? text;

  CheckBoxElement({
    required this.onChanged,
    this.disable = false,
    this.text,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          Container(
            width: 30,
            height: 30,
            child: Checkbox(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: value,
              tristate: disable,
              onChanged: disable ? null : onChanged,
              splashRadius: 0,
              activeColor: Colors.blueGrey,
              hoverColor: Colors.blueGrey.withOpacity(0.2),
            ),
          ),
          const SizedBox(width: 3),
          GestureDetector(
            onTap: disable ? null : () => onChanged(!value),
            child: Text(text ?? ''),
          ),
        ],
      ),
    );
  }
}
