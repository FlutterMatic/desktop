// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/meta/utils/app_theme.dart';

class CustomLinearProgressIndicator extends StatelessWidget {
  final bool includeBox;

  const CustomLinearProgressIndicator({
    Key? key,
    this.includeBox = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (includeBox) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).isDarkTheme
              ? const Color(0xff262F34)
              : Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.blueGrey.withOpacity(0.4)),
        ),
        padding: const EdgeInsets.all(10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            backgroundColor: Colors.blue.withOpacity(0.1),
          ),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LinearProgressIndicator(
          backgroundColor: Colors.blue.withOpacity(0.1),
        ),
      );
    }
  }
}
