import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_installer/screens/home_screen.dart';
import 'package:flutter_installer/screens/states_check.dart';
import 'package:flutter_installer/services/themes.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'dart:io';

Future<void> main() async {
  await currentTheme.initSharedPref();
  await currentTheme.loadThemePref();
  await checkPlatform();
  runApp(FlutterMain());
  doWhenWindowReady(() {
    appWindow.minSize = const Size(600, 500);
    appWindow.alignment = Alignment.center;
    appWindow.title = 'Flutter Installer';
    appWindow.show();
    appWindow.maximize();
  });
}

Future<void> checkPlatform() async {
  if (Platform.isWindows) {
    win32 = true;
  } else if (Platform.isMacOS) {
    mac = true;
  } else if (Platform.isLinux) {
    linux = true;
  }
}

class FlutterMain extends StatefulWidget {
  @override
  _FlutterMainState createState() => _FlutterMainState();
}

class _FlutterMainState extends State<FlutterMain> {
  @override
  void initState() {
    currentTheme.addListener(() => setState(() {}));
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result.index == 0 || result.index == 1) {
        connection = true;
      } else {
        connection = false;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    subscription!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    // TODO(yahu1031): Add providers on top of MyApp()
    // TODO(yahu1031): Add Scrcpy to share the device screen and mention
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
