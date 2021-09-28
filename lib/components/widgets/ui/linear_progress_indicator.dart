import 'package:flutter/material.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:provider/provider.dart';

class CustomLinearProgressIndicator extends StatelessWidget {
  const CustomLinearProgressIndicator({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.read<ThemeChangeNotifier>().isDarkTheme
            ? const Color(0xff262F34)
            : Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.blueGrey.withOpacity(0.4),
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LinearProgressIndicator(
          backgroundColor: Colors.blue.withOpacity(0.1),
        ),
      ),
    );
  }
}