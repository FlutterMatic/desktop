// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/shared_pref.dart';
import 'package:manager/app/providers/multi_providers.dart';
import 'package:manager/core/libraries/components.dart';
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/core/libraries/utils.dart';
import 'package:manager/core/libraries/views.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/meta/views/tabs/sections/pub/models/pkg_data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MultiProviders(FlutterMaticMain()));
  doWhenWindowReady(() {
    appWindow.minSize = const Size(750, 600);
    appWindow.maximize();
    appWindow.alignment = Alignment.center;
    appWindow.title = 'FlutterMatic';
    appWindow.show();
  });
}

class FlutterMaticMain extends StatefulWidget {
  const FlutterMaticMain({Key? key}) : super(key: key);

  @override
  _FlutterMaticMainState createState() => _FlutterMaticMainState();
}

class _FlutterMaticMainState extends State<FlutterMaticMain> {
  bool _isChecking = true;

  Future<void> _initDataFetch() async {
    try {
      await SpaceCheck().checkSpace();

      /// Application supporting Directory
      Directory _dir = await getApplicationSupportDirectory();

      /// Check for temporary Directory to download files
      bool _tmpDir = await Directory(_dir.path + '\\tmp').exists();
      bool _cacheDir = await Directory(_dir.path + '\\cache').exists();
      bool _logsDir = await Directory(_dir.path + '\\logs').exists();

      await SharedPref.init();

      if (kDebugMode) await SharedPref().pref.clear();

      appVersion = const String.fromEnvironment('current-version');

      await SharedPref()
          .pref
          .setString(SPConst.appVersion, appVersion.toString());

      appBuild = const String.fromEnvironment('release-type');

      await SharedPref().pref.setString(SPConst.appBuild, appBuild.toString());

      if (SharedPref().pref.containsKey(SPConst.completedSetup) &&
          !SharedPref().pref.containsKey(SPConst.setupTab)) {
        completedSetup =
            SharedPref().pref.getBool(SPConst.completedSetup) ?? false;
      } else {
        await SharedPref().pref.setBool(SPConst.completedSetup, false);
        completedSetup =
            SharedPref().pref.getBool(SPConst.completedSetup) ?? false;
      }

      if (!SharedPref().pref.containsKey(SPConst.sysPlatform)) {
        List<ProcessResult?>? platformData;

        if (Platform.isWindows) {
          platformData = await shell
              .run('systeminfo | findstr /B /C:"OS Name" /C:"OS Version"');
        } else {
          platformData = null;
        }

        await SharedPref()
            .pref
            .setString(SPConst.sysPlatform, Platform.operatingSystem)
            .then((_) => platform =
                SharedPref().pref.getString(SPConst.sysPlatform) ??
                    'Unknown Platform');

        platform = SharedPref().pref.getString(SPConst.sysPlatform) ??
            'Unknown Platform';

        await SharedPref()
            .pref
            .setString(
                SPConst.osName,
                platformData![0]!
                    .stdout
                    .toString()
                    .split('\n')[0]
                    .replaceAll('  ', '')
                    .replaceAll('OS Name: ', '')
                    .replaceAll('\\r', '')
                    .trim())
            .then((_) => osName = SharedPref().pref.getString(SPConst.osName) ??
                'Unknown OS Name');

        osName =
            SharedPref().pref.getString(SPConst.osName) ?? 'Unknown OS Name';

        await SharedPref().pref.setString(
            SPConst.osVersion,
            platformData[0]!
                .stdout
                .toString()
                .split('\n')[1]
                .replaceAll('  ', '')
                .replaceAll('OS Version', '')
                .replaceAll(':', '')
                .split('N/A')[0]
                .trim());

        osVersion = SharedPref().pref.getString(SPConst.osVersion) ??
            'Unknown OS Version';
      } else {
        platform = SharedPref().pref.getString(SPConst.sysPlatform) ??
            'Unknown Platform';
        osName =
            SharedPref().pref.getString(SPConst.osName) ?? 'Unknown OS Name';
        osVersion = SharedPref().pref.getString(SPConst.osVersion) ??
            'Unknown OS Version';
        appVersion = SharedPref().pref.getString(SPConst.appVersion) ??
            'Unknown App Version';
        appBuild = SharedPref().pref.getString(SPConst.appBuild) ??
            'Unknown App Build';
      }

      /// If tmpDir is false, then create a temporary directory.
      if (!_tmpDir) {
        await Directory(_dir.path + '\\tmp').create();
        await logger.file(LogTypeTag.info, 'Created tmp directory.');
      }

      // If cacheDir is false, then create a cache directory.
      if (!_cacheDir) {
        await Directory(_dir.path + '\\cache').create();
        await logger.file(LogTypeTag.info, 'Created cache directory.');
      }

      // If _logsDir is false, then create a cache directory.
      if (!_logsDir) {
        await Directory(_dir.path + '\\logs').create();
        await logger.file(LogTypeTag.info, 'Created logs directory.');
      }

      setState(() => _isChecking = false);

      await PkgViewData.getInitialPackages();
      await logger.file(LogTypeTag.info,
          'Background fetched the pub list for performance improvements.');
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Failed to initialize data fetch. $_',
          stackTraces: s);
      setState(() => _isChecking = false);
    }
  }

  @override
  void initState() {
    _initDataFetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RestartWidget(
      child: Consumer<ThemeChangeNotifier>(
        builder: (BuildContext context, ThemeChangeNotifier themeChangeNotifier,
            Widget? child) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: ColoredBox(
              color: themeChangeNotifier.isDarkTheme
                  ? AppTheme.darkBackgroundColor
                  : AppTheme.lightBackgroundColor,
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
                      builder: (_, Widget? child) {
                        return Stack(
                          children: <Widget>[
                            Center(child: child),
                            if (allowDevControls)
                              Positioned(
                                bottom: 10,
                                right: 10,
                                child: SquareButton(
                                  color: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  icon: Icon(
                                    context
                                            .read<ThemeChangeNotifier>()
                                            .isDarkTheme
                                        ? Icons.dark_mode
                                        : Icons.light_mode,
                                    color: context
                                            .read<ThemeChangeNotifier>()
                                            .isDarkTheme
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  onPressed: () {
                                    context
                                        .read<ThemeChangeNotifier>()
                                        .updateTheme(context
                                                .read<ThemeChangeNotifier>()
                                                .isDarkTheme
                                            ? Theme.of(context).brightness !=
                                                Brightness.light
                                            : Theme.of(context).brightness ==
                                                Brightness.light);
                                  },
                                ),
                              ),
                          ],
                        );
                      },
                      home: _isChecking
                          ? const Scaffold(
                              body: Center(child: Spinner(thickness: 2)))
                          : !completedSetup
                              ? const WelcomePage()
                              : const HomeScreen(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class RestartWidget extends StatefulWidget {
  final Widget child;

  const RestartWidget({required this.child, Key? key}) : super(key: key);

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() => setState(() => key = UniqueKey());

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: key, child: widget.child);
  }
}
