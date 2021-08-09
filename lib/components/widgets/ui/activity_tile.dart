import 'package:flutter/material.dart';
import 'package:manager/components/widgets/ui/spinner.dart';

class BgActivityTile extends StatelessWidget {
  final String title;
  final String activityId;

  const BgActivityTile({
    Key? key,
    required this.title,
    required this.activityId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 15),
        Row(
          children: <Widget>[
            Expanded(child: Text(title)),
            const SizedBox(width: 8),
            Spinner(thickness: 2, size: 15),
          ],
        ),
        const SizedBox(height: 15),
        ColoredBox(
          color: Colors.blueGrey.withOpacity(0.5),
          child: const SizedBox(width: double.infinity, height: 2),
        ),
      ],
    );
  }
}
