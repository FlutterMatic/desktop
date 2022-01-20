// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/libraries/constants.dart';

class ConfigureExpandableTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget icon;
  final List<Widget> children;

  const ConfigureExpandableTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        children: children,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headline1?.color,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            icon,
            HSeparators.normal(),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 15, color: Theme.of(context).iconTheme.color),
          ],
        ),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.symmetric(vertical: 10),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}
