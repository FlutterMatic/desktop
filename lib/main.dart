import 'package:bitsdojo_window_platform_interface/window.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:manager/app/providers/multi_ptoviders.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/meta/utils/app_theme.dart';
import 'package:manager/meta/views/startup.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPref.init();
  runApp(
    MultiProviders(
      MyApp(),
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
