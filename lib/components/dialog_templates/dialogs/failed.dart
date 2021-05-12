import 'package:flutter/material.dart';
import 'package:flutter_installer/components/widgets/dialog_template.dart';
import 'package:flutter_installer/components/widgets/rectangle_button.dart';
import 'package:flutter_installer/components/dialog_templates/dialog_header.dart';

class FailedDialog extends StatelessWidget {
  final String sorryText;
  final Function? onPressed;

  FailedDialog({required this.sorryText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      outerTapExit: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DialogHeader(title: 'Sorry'),
          const SizedBox(height: 20),
          Text(sorryText, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          RectangleButton(
            width: double.infinity,
            color: Colors.blueGrey,
            splashColor: Colors.blueGrey.withOpacity(0.5),
            focusColor: Colors.blueGrey.withOpacity(0.5),
            hoverColor: Colors.grey.withOpacity(0.5),
            highlightColor: Colors.blueGrey.withOpacity(0.5),
            onPressed: onPressed,
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
