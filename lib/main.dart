import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_installer/screens/home_screen.dart';
import 'package:flutter_installer/screens/states_check.dart';
import 'package:flutter_installer/services/themes.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'dart:ui';

Future<void> checkPlatform() async {
  if (Platform.isWindows) {
    win32 = true;
  } else if (Platform.isMacOS) {
    mac = true;
  } else if (Platform.isLinux) {
    linux = true;
  }
}

Future<void> main() async {
  await currentTheme.initSharedPref();
  // await apiCalls.flutterAPICall();
  await checkPlatform();
  // await apiCalls.flutterAPICall();
  runApp(MyApp());
  doWhenWindowReady(() {
    appWindow.minSize = const Size(500, 500);
    appWindow.alignment = Alignment.center;
    appWindow.title = 'Flutter Installer';
    appWindow.show();
    appWindow.maximize();
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    currentTheme.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: CustomTheme.lightTheme,
      darkTheme: CustomTheme.darkTheme,
      themeMode: currentTheme.currentTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: PageRoutes.routeState,
      routes: <String, WidgetBuilder>{
        PageRoutes.routeState: (BuildContext context) => const StatusCheck(),
        PageRoutes.routeHome: (BuildContext context) => HomeScreen(),
      },
    );
  }
}
