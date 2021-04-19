import 'package:flutter/material.dart';
import 'package:flutter_installer/utils/constants.dart';

class CheckBoxElement extends StatelessWidget {
  final bool value;
  final Function(bool?) onChanged;
  final String? text;

  CheckBoxElement({
    required this.onChanged,
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
            onChanged: onChanged,
            splashRadius: 20,
            activeColor: Colors.blueGrey,
            hoverColor: Colors.blueGrey.withOpacity(0.2),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text ?? '')),
        ],
      ),
    );
  }
}
