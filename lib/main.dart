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
  runApp(RestartWidget(child: MultiProviders(FlutterMaticMain())));
  doWhenWindowReady(() {
    appWindow.minSize = const Size(750, 600);
    appWindow.maximize();
    appWindow.alignment = Alignment.center;
    appWindow.title = 'Flutter Manager';
    appWindow.show();
  });
}

class FlutterMaticMain extends StatefulWidget {
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
          child: _CustomWindow(
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
        );
      },
    );
  }
}

class _CustomWindow extends StatelessWidget {
  final Widget child;

  _CustomWindow({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.read<ThemeChangeNotifier>().isDarkTheme
          ? AppTheme.darkBackgroundColor
          : AppTheme.lightBackgroundColor,
      child: Column(
        children: <Widget>[
          WindowTitleBarBox(
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Flutter App Manager',
                    style: TextStyle(
                      fontSize: 12,
                      color: !context.read<ThemeChangeNotifier>().isDarkTheme
                          ? AppTheme.darkBackgroundColor
                          : AppTheme.lightBackgroundColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
                Expanded(child: MoveWindow()),
                windowControls(context)
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class RestartWidget extends StatefulWidget {
  RestartWidget({required this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()!.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
