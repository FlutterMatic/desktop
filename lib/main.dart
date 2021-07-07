import 'package:bitsdojo_window_platform_interface/window.dart'
    show DesktopWindow;
import 'package:flutter/material.dart'
    show
        Alignment,
        BuildContext,
        MaterialApp,
        Size,
        StatelessWidget,
        ThemeMode,
        Widget,
        WidgetsFlutterBinding,
        runApp;
import 'package:bitsdojo_window/bitsdojo_window.dart'
    show appWindow, doWhenWindowReady;
import 'package:flutter/src/widgets/basic.dart' show Alignment, Size;
import 'package:manager/core/notifiers/theme.notifier.dart'
    show ThemeChangeNotifier;
import 'package:manager/core/services/checks/flutter.check.dart';
import 'package:manager/meta/utils/app_theme.dart' show AppTheme;
import 'package:manager/meta/views/startup.dart' show Startup;
import 'package:provider/provider.dart'
    show ChangeNotifierProvider, Consumer, MultiProvider;
import 'package:provider/single_child_widget.dart' show SingleChildWidget;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<ThemeChangeNotifier>(
          create: (_) => ThemeChangeNotifier(),
        ),
        ChangeNotifierProvider<FlutterCheck>(
          create: (_) => FlutterCheck(),
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
