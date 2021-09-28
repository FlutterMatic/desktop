import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:manager/meta/utils/app_theme.dart';
import 'package:manager/meta/utils/shared_pref.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/components.dart';
import 'package:manager/core/notifiers/space.notifier.dart';
import 'package:manager/app/providers/multi_providers.dart';
import 'package:manager/components/widgets/ui/spinner.dart';
import 'package:manager/meta/views/welcome/screens/welcome_view.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:manager/meta/views/home/home.dart';
import 'package:provider/provider.dart';
import 'dart:io';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MultiProviders(FlutterMaticMain()));
  doWhenWindowReady(() {
    appWindow.minSize = const Size(750, 600);
    appWindow.maximize();
    appWindow.alignment = Alignment.center;
    appWindow.title = 'Flutter Manager';
    appWindow.show();
  });
}

class FlutterMaticMain extends StatefulWidget {
  const FlutterMaticMain({Key? key}) : super(key: key);

  @override
  _FlutterMaticMainState createState() => _FlutterMaticMainState();
}

class _FlutterMaticMainState extends State<FlutterMaticMain> {
  bool isChecking = true;

  Future<void> _initDataFetch() async {
    await SpaceCheck().checkSpace();

    /// Application supporting Directory
    Directory dir = await getApplicationSupportDirectory();

    /// Check for temporary Directory to download files
    bool tmpDir = await Directory('${dir.path}\\tmp').exists();
    bool appDir = await Directory('C:\\fluttermatic').exists();

    await SharedPref.init();

    if (kDebugMode || kProfileMode) await SharedPref().pref.clear();

    appVersion = const String.fromEnvironment('current-version');
    await SharedPref().pref.setString('App_Version', appVersion.toString());
    appBuild = const String.fromEnvironment('release-type');
    await SharedPref().pref.setString('App_Build', appBuild.toString());
    if (SharedPref().pref.containsKey('All_Checked') &&
        !SharedPref().pref.containsKey('Tab')) {
      allChecked = SharedPref().pref.getBool('All_Checked');
    } else {
      await SharedPref().pref.setBool('All_Checked', false);
      allChecked = SharedPref().pref.getBool('All_Checked');
    }
    if (!SharedPref().pref.containsKey('platform')) {
      List<ProcessResult?>? platformData = Platform.isWindows
          ? await shell
              .run('systeminfo | findstr /B /C:"OS Name" /C:"OS Version"')
          : null;
      await SharedPref()
          .pref
          .setString('platform', Platform.operatingSystem)
          .then((_) => platform = SharedPref().pref.getString('platform'));
      platform = SharedPref().pref.getString('platform');
      await SharedPref()
          .pref
          .setString(
              'OS_Name',
              platformData![0]!
                  .stdout
                  .split('\n')[0]
                  .replaceAll('  ', '')
                  .replaceAll('OS Name: ', '')
                  .replaceAll('\\r', '')
                  .trim())
          .then((_) => osName = SharedPref().pref.getString('OS_Name'));
      osName = SharedPref().pref.getString('OS_Name');
      await SharedPref().pref.setString(
          'OS_Version',
          platformData[0]!
              .stdout
              .split('\n')[1]
              .replaceAll('  ', '')
              .replaceAll('OS Version', '')
              .replaceAll(':', '')
              .split('N/A')[0]
              .trim());
      osVersion = SharedPref().pref.getString('OS_Version');
    } else {
      platform = SharedPref().pref.getString('platform');
      osName = SharedPref().pref.getString('OS_Name');
      osVersion = SharedPref().pref.getString('OS_Version');
      appTemp = SharedPref().pref.getString('App_Temp_Dir');
      appMainDir = SharedPref().pref.getString('App_Main_Dir');
      appVersion = SharedPref().pref.getString('App_Version');
      appBuild = SharedPref().pref.getString('App_Build');
    }

    /// If tmpDir is false, then create a temporary directory.
    if (!tmpDir) {
      await Directory('${dir.path}\\tmp').create();
      await logger.file(LogTypeTag.info, 'Created tmp directory.');
    }

    /// If appDir is false, then create a app directory.
    if (!appDir) {
      await Directory('C:\\fluttermatic').create();
      await logger.file(LogTypeTag.info, 'Created fluttermatic directory.');
    }

    setState(() => isChecking = false);
  }

  @override
  void initState() {
    _initDataFetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeChangeNotifier>(
      builder: (BuildContext context, ThemeChangeNotifier themeChangeNotifier,
          Widget? child) {
        return Directionality(
            textDirection: TextDirection.ltr,
            child: Container(
              color: themeChangeNotifier.isDarkTheme ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor,
              child: Column(
                children: <Widget>[
                  WindowTitleBarBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: Image.asset(Assets.appLogo),
                        ),
                        Expanded(child: MoveWindow()),
                        windowControls(context)
                      ],
                    ),
                  ),
                  Expanded(
                    child: MaterialApp(
                      theme: AppTheme.lightTheme,
                      darkTheme: AppTheme.darkTheme,
                      themeMode: themeChangeNotifier.isDarkTheme
                          ? ThemeMode.dark
                          : ThemeMode.light,
                      debugShowCheckedModeBanner: false,
                      home: isChecking
                          ? const Scaffold(body: Center(child: Spinner()))
                          : !allChecked!
                              ? const WelcomePage()
                              : const HomeScreen(),
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }
}
