// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/shared_pref.dart';
import 'package:fluttermatic/components/dialog_templates/other/unofficial_release.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/spinner.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/theme.dart';
import 'package:fluttermatic/core/notifiers/notifiers/general/theme.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/general/app_theme.dart';
import 'package:fluttermatic/meta/utils/general/shared_pref.dart';
import 'package:fluttermatic/meta/views/setup/components/windows_controls.dart';
import 'package:fluttermatic/meta/views/tabs/home.dart';
import 'meta/views/setup/screens/setup_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    Directory basePath = await getApplicationSupportDirectory();
    print('📂 AppData path: ${basePath.path}');
  }

  // Initialize shared preference.
  await SharedPref.init();

  // The bitsdojo window plugin fails to compile when trying to hide the
  // window controls on Windows natively.
  await windowManager
      .waitUntilReadyToShow()
      .then((_) => windowManager.setFullScreen(true));

  doWhenWindowReady(() {
    appWindow.minSize = const Size(750, 600);
    appWindow.alignment = Alignment.center;
    appWindow.title = 'FlutterMatic';
    appWindow.show();
    appWindow.maximize();
  });
  // Wrapped with a restart widget to allow restarting FlutterMatic from
  // anywhere in the app without restarting Flutter engine.
  runApp(const RestartWidget(child: ProviderScope(child: FlutterMaticMain())));
}

class FlutterMaticMain extends ConsumerStatefulWidget {
  const FlutterMaticMain({Key? key}) : super(key: key);

  @override
  _FlutterMaticMainState createState() => _FlutterMaticMainState();
}

class _FlutterMaticMainState extends ConsumerState<FlutterMaticMain> {
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
      Directory dir = await getApplicationSupportDirectory();

      // List of directories that needs to be ensured that they exist.
      List<String> dirsToCreate = <String>[
        '\\logs',
        '\\cache',
        '\\tmp',
      ];

      // Create each directory if they are missing.
      for (String dirName in dirsToCreate) {
        Directory dirToCreate = Directory(dir.path + dirName);
        if (!await dirToCreate.exists()) {
          await dirToCreate.create(recursive: true);
        }
      }

      await ref.watch(spaceStateController.notifier).checkSpace();

      // Keeps on monitoring the network connection and updates any listener
      // when the connection changes.
      await ref.watch(connectionNotifierController.notifier).initConnectivity();

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
    } catch (e, s) {
      await logger.file(LogTypeTag.error, 'Failed to initialize data fetch.',
          error: e, stackTrace: s);

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
    return Consumer(
      builder: (_, WidgetRef ref, __) {
        ThemeState themeState = ref.watch(themeStateController);
        ThemeNotifier themeNotifier = ref.watch(themeStateController.notifier);

        return Directionality(
          textDirection: TextDirection.ltr,
          child: ColoredBox(
            color: themeState.darkTheme
                ? AppTheme.darkBackgroundColor
                : AppTheme.lightBackgroundColor,
            child: Column(
              children: <Widget>[
                WindowTitleBarBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(child: MoveWindow()),
                      if (Platform.isWindows) windowControls(context),
                    ],
                  ),
                ),
                Expanded(
                  child: MaterialApp(
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode:
                        themeState.darkTheme ? ThemeMode.dark : ThemeMode.light,
                    debugShowCheckedModeBanner: false,
                    builder: (_, Widget? child) {
                      ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                        // Log the render error to the log file so we can see it.
                        logger.file(
                          LogTypeTag.error,
                          'Error while building UI: ${errorDetails.exception}',
                          stackTrace: errorDetails.stack,
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
                                  themeState.darkTheme
                                      ? Icons.dark_mode
                                      : Icons.light_mode,
                                  color: themeState.darkTheme
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                onPressed: () {
                                  themeNotifier.updateTheme(themeState.darkTheme
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
                    home: Consumer(
                      builder: (_, ref, __) {
                        // Make sure this is an official build of the app.
                        if (appBuild.isEmpty || appVersion.isEmpty) {
                          return const UnofficialReleaseDialog();
                        }

                        if (_isChecking) {
                          return const Scaffold(
                              body: Center(child: Spinner(thickness: 2)));
                        } else if (completedSetup) {
                          return const HomeScreen();
                        } else {
                          return const SetupScreen();
                        }
                      },
                    ),
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
