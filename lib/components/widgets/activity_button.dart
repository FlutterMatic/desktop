import 'package:flutter/material.dart';

class BgActivityButton extends StatelessWidget {
  final String title;
  final String activityId;

  BgActivityButton({
    required this.title,
    required this.activityId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: Text(title)),
            const SizedBox(width: 8),
            const SizedBox(
                height: 15,
                width: 15,
                child: Tooltip(
                    message: 'In progress...',
                    child: CircularProgressIndicator(strokeWidth: 2))),
          ],
        ),
        const SizedBox(height: 15),
        Container(
            color: Colors.blueGrey.withOpacity(0.5),
            width: double.infinity,
            height: 2),
      ],
    );
  }
}

