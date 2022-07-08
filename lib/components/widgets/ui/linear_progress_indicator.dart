// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/theme.dart';
import 'package:fluttermatic/core/notifiers/out.dart';

class CustomLinearProgressIndicator extends StatelessWidget {
  final bool includeBox;

  const CustomLinearProgressIndicator({
    Key? key,
    this.includeBox = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (includeBox) {
      return Consumer(
        builder: (_, ref, __) {
          ThemeState themeState = ref.watch(themeStateController);

          return Container(
            decoration: BoxDecoration(
              color: themeState.isDarkTheme
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
        },
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
