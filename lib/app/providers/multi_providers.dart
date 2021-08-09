import 'package:flutter/material.dart';
import 'package:manager/core/libraries/api.dart';
import 'package:manager/core/libraries/checks.dart';
import 'package:manager/core/libraries/notifiers.dart';
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
        ChangeNotifierProvider<MainChecksNotifier>(
          create: (BuildContext context) => MainChecksNotifier(),
        ),
        ChangeNotifierProvider<FlutterChangeNotifier>(
          create: (BuildContext context) => FlutterChangeNotifier(),
        ),
        ChangeNotifierProvider<JavaChangeNotifier>(
          create: (BuildContext context) => JavaChangeNotifier(),
        ),
        ChangeNotifierProvider<ADBChangeNotifier>(
          create: (BuildContext context) => ADBChangeNotifier(),
        ),
        ChangeNotifierProvider<VSCodeChangeNotifier>(
          create: (BuildContext context) => VSCodeChangeNotifier(),
        ),
        ChangeNotifierProvider<GitChangeNotifier>(
          create: (BuildContext context) => GitChangeNotifier(),
        ),
        ChangeNotifierProvider<AndroidStudioChangeNotifier>(
          create: (BuildContext context) => AndroidStudioChangeNotifier(),
        ),
        ChangeNotifierProvider<ThemeChangeNotifier>(
          create: (BuildContext context) => ThemeChangeNotifier(),
        ),
      ],
      child: child,
    );
  }
}
