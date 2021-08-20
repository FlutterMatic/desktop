import 'package:flutter/material.dart';
import 'package:manager/core/libraries/components.dart';
import 'package:manager/core/notifiers/space.notifier.dart';
import 'package:manager/meta/utils/app_theme.dart';
import 'package:manager/meta/utils/shared_pref.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/app/providers/multi_providers.dart';
import 'package:manager/meta/views/welcome/screens/welcome_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:manager/core/libraries/services.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await SpaceCheck().checkSpace();

  /// Application supporting Directory
  Directory dir = await getApplicationSupportDirectory();

  /// Check for temporary Directory to download files
  bool tmpDir = await Directory('${dir.path}\\tmp').exists();
  bool appDir = await Directory('C:\\fluttermatic').exists();

  await SharedPref.init();
  if (!SharedPref().prefs.containsKey('platform')) {
    List<ProcessResult?>? platformData = Platform.isWindows
        ? await shell
            .run('systeminfo | findstr /B /C:"OS Name" /C:"OS Version"')
        : null;
    await SharedPref()
        .prefs
        .setString('platform', Platform.operatingSystem)
        .then((_) => platform = SharedPref().prefs.getString('platform'));
    platform = SharedPref().prefs.getString('platform');
    await SharedPref()
        .prefs
        .setString(
            'OS Name',
            platformData![0]!
                .stdout
                .split('\n')[0]
                .replaceAll('  ', '')
                .replaceAll('OS Name: ', '')
                .replaceAll('\\r', '')
                .trim())
        .then((_) => osName = SharedPref().prefs.getString('OS Name'));
    osName = SharedPref().prefs.getString('OS Name');
    await SharedPref().prefs.setString(
        'OS Version',
        platformData[0]!
            .stdout
            .split('\n')[1]
            .replaceAll('  ', '')
            .replaceAll('OS Version', '')
            .split('N/A')[0]
            .trim());
    osVersion = SharedPref().prefs.getString('OS Version');
  } else {
    platform = SharedPref().prefs.getString('platform');
    osName = SharedPref().prefs.getString('OS Name');
    osVersion = SharedPref().prefs.getString('OS Version');
    appTemp = SharedPref().prefs.getString('App Temp Dir');
    appMainDir = SharedPref().prefs.getString('App Main Dir');
  }

  /// If tmpDir is false, then create a temporary directory.
  if (!tmpDir) {
    await Directory('${dir.path}\\tmp').create();
    await logger.file(LogTypeTag.INFO, 'Created tmp directory.');
  }

  /// If appDir is false, then create a app directory.
  if (!appDir) {
    await Directory('C:\\fluttermatic').create();
    await logger.file(LogTypeTag.INFO, 'Created fluttermatic directory.');
  }
  runApp(MultiProviders(MyApp()));
  doWhenWindowReady(() {
    appWindow.minSize = const Size(750, 680);
    appWindow.maximize();
    appWindow.alignment = Alignment.center;
    appWindow.title = 'Flutter Manager';
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeChangeNotifier>(
      builder: (BuildContext context, ThemeChangeNotifier themeChangeNotifier,
          Widget? child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: CustomWindow(
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeChangeNotifier.isDarkTheme
                  ? ThemeMode.dark
                  : ThemeMode.light,
              debugShowCheckedModeBanner: false,
              home: const WelcomePage(),
            ),
          ),
        );
      },
    );
  }
}