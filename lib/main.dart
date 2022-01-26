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
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/app/constants/shared_pref.dart';
import 'package:fluttermatic/app/providers/multi_providers.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/spinner.dart';
import 'package:fluttermatic/components/widgets/ui/warning_widget.dart';
import 'package:fluttermatic/core/notifiers/connection.notifier.dart';
import 'package:fluttermatic/core/notifiers/space.notifier.dart';
import 'package:fluttermatic/core/notifiers/theme.notifier.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';
import 'package:fluttermatic/meta/utils/shared_pref.dart';
import 'package:fluttermatic/meta/views/setup/components/windows_controls.dart';
import 'package:fluttermatic/meta/views/tabs/home.dart';
import 'package:fluttermatic/meta/views/tabs/sections/pub/models/pkg_data.dart';
import 'meta/views/setup/screens/setup_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory _basePath = await getApplicationSupportDirectory();
  debugPrint('📂 AppData path: ${_basePath.path}');
  doWhenWindowReady(() {
    appWindow.minSize = const Size(750, 600);
    appWindow.alignment = Alignment.center;
    appWindow.title = 'FlutterMatic';
    appWindow.show();
    appWindow.maximize();
  });
  // Wrapped with a restart widget to allow restarting FlutterMatic from
  // anywhere in the app without restarting Flutter engine.
  runApp(const RestartWidget(child: MultiProviders(FlutterMaticMain())));
}

class FlutterMaticMain extends StatefulWidget {
  const FlutterMaticMain({Key? key}) : super(key: key);

  @override
  _FlutterMaticMainState createState() => _FlutterMaticMainState();
}

class _FlutterMaticMainState extends State<FlutterMaticMain> {
  // Utils
  bool _isChecking = true;

  Future<void> _hasCompletedSetup() async {
    if (SharedPref().pref.containsKey(SPConst.completedSetup) &&
        !SharedPref().pref.containsKey(SPConst.setupTab)) {
      completedSetup =
          SharedPref().pref.getBool(SPConst.completedSetup) ?? false;
    } else {
      await SharedPref().pref.setBool(SPConst.completedSetup, false);
      completedSetup =
          SharedPref().pref.getBool(SPConst.completedSetup) ?? false;
    }
  }

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

      // Keeps on monitoring the network connection and updates any listener
      // when the connection changes.
      await ConnectionNotifier().initConnectivity();

      // if (kDebugMode) await SharedPref().pref.clear();

      await SharedPref()
          .pref
          .setString(SPConst.appVersion, appVersion.toString());

      await SharedPref().pref.setString(SPConst.appBuild, appBuild.toString());

      await _hasCompletedSetup();

      if (!SharedPref().pref.containsKey(SPConst.sysPlatform)) {
        List<ProcessResult> platformData = <ProcessResult>[];

        switch (Platform.operatingSystem) {
          case 'windows':
            platformData = await shell
                .run('systeminfo | findstr /B /C:"OS Name" /C:"OS Version"');
            break;
          case 'linux':
            // TODO: Get linux platform data.
            break;
          case 'macos':
            // TODO: Get macos platform data.
            break;
          default:
            platformData = <ProcessResult>[];
        }

        await SharedPref()
            .pref
            .setString(SPConst.sysPlatform, Platform.operatingSystem)
            .then((_) {
          return platform = SharedPref().pref.getString(SPConst.sysPlatform) ??
              Platform.operatingSystem;
        });

        platform = SharedPref().pref.getString(SPConst.sysPlatform) ??
            Platform.operatingSystem;

        await SharedPref()
            .pref
            .setString(
                SPConst.osName,
                platformData[0]
                    .stdout
                    .toString()
                    .split('\n')[0]
                    .replaceAll('  ', '')
                    .replaceAll('OS Name: ', '')
                    .replaceAll('\\r', '')
                    .trim())
            .then((_) {
          return osName = SharedPref().pref.getString(SPConst.osName) ??
              Platform.operatingSystem;
        });

        osName = SharedPref().pref.getString(SPConst.osName) ??
            Platform.operatingSystem;

        await SharedPref().pref.setString(
            SPConst.osVersion,
            platformData[0]
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

      // Get the package every hour to avoid loading it and waiting when the
      // user goes to the packages tab in home.
      while (mounted) {
        await PkgViewData.getInitialPackages();

        await logger.file(LogTypeTag.info,
            'Background fetched the pub list for performance improvements.');

        await Future<void>.delayed(const Duration(hours: 1));
      }
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Failed to initialize data fetch. $_',
          stackTraces: s);
      await _hasCompletedSetup();
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
    return Consumer<ThemeChangeNotifier>(
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
                      if (Platform.isWindows) windowControls(context)
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
                      ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                        // Log the render error to the log file so we can see it.
                        logger.file(
                          LogTypeTag.error,
                          'Error while building UI: ${errorDetails.exception}',
                          stackTraces: errorDetails.stack,
                        );
                        if (!kReleaseMode) {
                          return ErrorWidget(errorDetails.exception);
                        } else {
                          return Scaffold(
                            body: Material(
                              color: Colors.transparent,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      const Text(
                                        'Rendering Error - Restart App',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      VSeparators.normal(),
                                      SelectableText(
                                          'Error: ${errorDetails.exception}'),
                                      VSeparators.normal(),
                                      informationWidget(
                                          'Please report this error by generating report in settings and filing a bug report on GitHub. To do that, close and reopen the app, go to Settings > GitHub > Create Issue.'),
                                      VSeparators.normal(),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: SelectableText(
                                              'StackTrace: ${errorDetails.stack}'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      };

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
                            ? const SetupScreen()
                            : const HomeScreen(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
