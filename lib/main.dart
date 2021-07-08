import 'package:bitsdojo_window_platform_interface/window.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:manager/core/notifiers/change.notifier.dart';
import 'package:manager/core/notifiers/flutter.notifier.dart';
import 'package:manager/core/notifiers/java.notifier.dart';
import 'package:manager/core/notifiers/theme.notifier.dart';
import 'package:manager/meta/utils/app_theme.dart';
import 'package:manager/meta/views/startup.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<MainChecksNotifier>(
          create: (BuildContext context) => MainChecksNotifier(),
        ),
        ChangeNotifierProvider<FlutterChangeNotifier>(
          create: (BuildContext context) => FlutterChangeNotifier(),
        ),
        ChangeNotifierProvider<JavaChangeNotifier>(
          create: (BuildContext context) => JavaChangeNotifier(),
        ),
        ChangeNotifierProvider<ThemeChangeNotifier>(
          create: (BuildContext context) => ThemeChangeNotifier(),
        ),
      ],
      child: MyApp(),
    ),
  );

  doWhenWindowReady(() {
    DesktopWindow win = appWindow;
    Size initialSize = const Size(300, 380);
    win.minSize = initialSize;
    win.maxSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = 'Flutter App Manager';
    win.show();
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeChangeNotifier>(
      builder: (BuildContext context, ThemeChangeNotifier themeChangeNotifier,
          Widget? child) {
        return MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeChangeNotifier.isDarkTheme
              ? ThemeMode.dark
              : ThemeMode.light,
          debugShowCheckedModeBanner: false,
          home: Startup(themeChangeNotifier),
          // home: const ThemeToggle(),
        );
      },
    );
  }
}