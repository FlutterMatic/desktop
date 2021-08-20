import 'package:flutter/material.dart';
import 'package:manager/core/libraries/api.dart';
import 'package:manager/core/libraries/checks.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/notifiers/space.notifier.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class MultiProviders extends StatelessWidget {
  MultiProviders(this.child, {Key? key}) : super(key: key);

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<ConnectionNotifier>(
          create: (BuildContext context) => ConnectionNotifier(),
        ),
        ChangeNotifierProvider<DownloadNotifier>(
          create: (BuildContext context) => DownloadNotifier(),
        ),
        ChangeNotifierProvider<VSCodeAPINotifier>(
          create: (BuildContext context) => VSCodeAPINotifier(),
        ),
        ChangeNotifierProvider<FlutterMaticAPINotifier>(
          create: (BuildContext context) => FlutterMaticAPINotifier(),
        ),
        ChangeNotifierProvider<FlutterSDKNotifier>(
          create: (BuildContext context) => FlutterSDKNotifier(),
        ),
        ChangeNotifierProvider<FlutterNotifier>(
          create: (BuildContext context) => FlutterNotifier(),
        ),
        ChangeNotifierProvider<JavaNotifier>(
          create: (BuildContext context) => JavaNotifier(),
        ),
        ChangeNotifierProvider<ADBNotifier>(
          create: (BuildContext context) => ADBNotifier(),
        ),
        ChangeNotifierProvider<VSCodeNotifier>(
          create: (BuildContext context) => VSCodeNotifier(),
        ),
        ChangeNotifierProvider<GitNotifier>(
          create: (BuildContext context) => GitNotifier(),
        ),
        ChangeNotifierProvider<AndroidStudioNotifier>(
          create: (BuildContext context) => AndroidStudioNotifier(),
        ),
        ChangeNotifierProvider<ThemeChangeNotifier>(
          create: (BuildContext context) => ThemeChangeNotifier(),
        ),
        ChangeNotifierProvider<SpaceCheck>(
          create: (BuildContext context) => SpaceCheck(),
        ),
      ],
      child: child,
    );
  }
}
