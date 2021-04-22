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
        children: [
          Checkbox(
            value: value,
            onChanged: disable ? null : onChanged,
            splashRadius: 0,
            activeColor: Colors.blueGrey,
            hoverColor: Colors.blueGrey.withOpacity(0.2),
          ),
          const SizedBox(width: 3),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(value),
              child: Text(text ?? ''),
            ),
          ),
        ],
      ),
    );
  }
}
