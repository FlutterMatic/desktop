import 'dart:ui';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_installer/screens/check_states.dart';
import 'package:flutter_installer/screens/splash_screen.dart';
import 'package:flutter_installer/utils/constants.dart';

Future<void> main() async {
  runApp(
    MyApp(),
  );
  doWhenWindowReady(() {
    Size initialSize =
        Size(window.physicalSize.width / 2, window.physicalSize.height / 2);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Installer',
        initialRoute: PageRoutes.routeHome,
        routes: <String, WidgetBuilder>{
          PageRoutes.routeHome: (BuildContext context) => const SplashScreen(),
          PageRoutes.routeState: (BuildContext context) => CheckStates(),
        },
      );
}
