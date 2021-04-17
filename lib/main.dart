import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_installer/screens/check_states.dart';
import 'dart:ui';

Future<void> main() async {
  runApp(MyApp());
  doWhenWindowReady(() {
    Size initialSize =
        Size(window.physicalSize.width / 2, window.physicalSize.height / 2);
    appWindow.minSize = const Size(200, 500);
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Installer',
      home: CheckStates(),
    );
  }
}
