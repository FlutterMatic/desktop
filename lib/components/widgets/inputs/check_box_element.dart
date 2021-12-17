// 🐦 Flutter imports:
import 'package:flutter/material.dart';

class CheckBoxElement extends StatelessWidget {
  final bool value;
  final bool disable;
  final Function(bool?) onChanged;
  final String? text;

  const CheckBoxElement({
    Key? key,
    required this.onChanged,
    this.disable = false,
    this.text,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          SizedBox(
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
