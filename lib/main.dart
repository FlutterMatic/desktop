import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_installer/screens/home/home_screen.dart';
import 'package:flutter_installer/screens/states_check.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'dart:ui';

Future<void> main() async {
  runApp(MyApp());
  doWhenWindowReady(() {
    appWindow.minSize = const Size(500, 500);
    appWindow.alignment = Alignment.center;
    appWindow.title = 'Flutter Installer';
    appWindow.show();
    appWindow.maximize();
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: PageRoutes.routeState,
        routes: <String, WidgetBuilder>{
          PageRoutes.routeState: (BuildContext context) => const StatusCheck(),
          PageRoutes.routeHome: (BuildContext context) => HomeScreen(),
        },
      );
}
