// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/shared_pref.dart';
import 'package:fluttermatic/app/providers/multi_providers.dart';
import 'package:fluttermatic/core/libraries/components.dart';
import 'package:fluttermatic/core/libraries/constants.dart';
import 'package:fluttermatic/core/libraries/notifiers.dart';
import 'package:fluttermatic/core/libraries/services.dart';
import 'package:fluttermatic/core/libraries/utils.dart';
import 'package:fluttermatic/core/libraries/views.dart';
import 'package:fluttermatic/core/libraries/widgets.dart';
import 'package:fluttermatic/meta/views/tabs/sections/pub/models/pkg_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory _basePath = await getApplicationSupportDirectory();
  debugPrint('📂 Logs path: ${join(_basePath.path, 'logs')}');
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
      /// Application supporting Directory
      Directory _dir = await getApplicationSupportDirectory();

      /// Check for temporary Directory to download files
      bool _logsDir = await Directory(_dir.path + '\\logs').exists();
      bool _cacheDir = await Directory(_dir.path + '\\cache').exists();
      bool _tmpDir = await Directory(_dir.path + '\\tmp').exists();

      // If _logsDir is false, then create a cache directory.
      if (!_logsDir) {
        await Directory(_dir.path + '\\logs').create();
        await logger.file(LogTypeTag.info, 'Created logs directory.');
      }

      // If cacheDir is false, then create a cache directory.
      if (!_cacheDir) {
        await Directory(_dir.path + '\\cache').create();
        await logger.file(LogTypeTag.info, 'Created cache directory.');
      }

      /// If tmpDir is false, then create a temporary directory.
      if (!_tmpDir) {
        await Directory(_dir.path + '\\tmp').create();
        await logger.file(LogTypeTag.info, 'Created tmp directory.');
      }

      // Initialize shared preference.
      await SharedPref.init();

      // Calculate the space on the disk(s).
      await SpaceCheck().checkSpace();

      if (kDebugMode) await SharedPref().pref.clear();

      appVersion = const String.fromEnvironment('CURRENT_VERSION');

      await SharedPref()
          .pref
          .setString(SPConst.appVersion, appVersion.toString());

      appBuild = const String.fromEnvironment('RELEASE_TYPE');

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
                    Platform.operatingSystem);

        platform = SharedPref().pref.getString(SPConst.sysPlatform) ??
            Platform.operatingSystem;

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
                Platform.operatingSystem);

        osName = SharedPref().pref.getString(SPConst.osName) ??
            Platform.operatingSystem;

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
            Platform.operatingSystemVersion;
      } else {
        platform = SharedPref().pref.getString(SPConst.sysPlatform) ??
            Platform.operatingSystem;
        osName = SharedPref().pref.getString(SPConst.osName) ??
            Platform.operatingSystem;
        osVersion = SharedPref().pref.getString(SPConst.osVersion) ??
            Platform.operatingSystemVersion;
        appVersion = SharedPref().pref.getString(SPConst.appVersion) ??
            'Unknown App Version';
        appBuild = SharedPref().pref.getString(SPConst.appBuild) ??
            'Unknown App Build';
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
