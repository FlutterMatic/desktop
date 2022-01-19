// 🎯 Dart imports:
import 'dart:async';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/shared_pref.dart';
import 'package:manager/core/libraries/checks.dart';
import 'package:manager/core/libraries/components.dart';
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/sections.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/core/libraries/utils.dart';
import 'package:manager/core/libraries/views.dart';
import 'package:manager/core/libraries/widgets.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  WelcomeTab _tab = WelcomeTab.gettingStarted;
  bool _installing = false;
  bool _completedInstall = false;

  // Editor(s) to install.
  final List<EditorType> _editor = <EditorType>[
    EditorType.androidStudio,
    EditorType.vscode,
  ];

  @override
  void initState() {
    // setState(() => _tab = WelcomeTab.installEditor);
    if (SharedPref().pref.containsKey(SPConst.setupTab)) {
      setState(() => _tab = WelcomeTab.restart);
    } else {
      setState(() => _tab = WelcomeTab.gettingStarted);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: <Widget>[
                createWelcomeHeader(_tab, context),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SizedBox(
                      width: 415,
                      child: Center(
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context)
                              .copyWith(scrollbars: false),
                          child: SingleChildScrollView(
                            child: _getCurrentPage(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15, top: 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextButton(
                        style: ButtonStyle(
                          splashFactory: NoSplash.splashFactory,
                          overlayColor: MaterialStateProperty.all<Color>(
                              Colors.transparent),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.transparent),
                        ),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => const FlutterRequirementsDialog(),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'System Requirements',
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).isDarkTheme
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ),
                      ),
                      HSeparators.xSmall(),
                      TextButton(
                        style: ButtonStyle(
                          splashFactory: NoSplash.splashFactory,
                          overlayColor: MaterialStateProperty.all<Color>(
                              Colors.transparent),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.transparent),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const SetupDocsScreen(),
                          );
                          // Navigator.push(
                          //   context,
                          //   PageRouteBuilder<Route<dynamic>>(
                          //     pageBuilder: (_, __, ___) =>
                          //         const SetupDocsScreen(),
                          //     transitionDuration: Duration.zero,
                          //   ),
                          // );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'Docs & Tutorials',
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).isDarkTheme
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Row(
              children: <Widget>[
                IconButton(
                  splashRadius: 1,
                  icon: Icon(
                    Theme.of(context).isDarkTheme
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                  ),
                  onPressed: () {
                    context
                        .read<ThemeChangeNotifier>()
                        .updateTheme(!Theme.of(context).isDarkTheme);
                    setState(() {});
                  },
                ),
                HSeparators.xSmall(),
                IconButton(
                  splashRadius: 1,
                  icon: const Icon(Icons.info_outline_rounded),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const AboutUsDialog(),
                    );
                  },
                ),
              ],
            ),
          ),
          if (allowDevControls)
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                splashRadius: 1,
                icon: const Icon(Icons.skip_next),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute<Widget>(
                      builder: (_) => const HomeScreen(),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _getCurrentPage(BuildContext context) {
    switch (_tab) {
      case WelcomeTab.gettingStarted:
        return WelcomeGettingStarted(
          onContinue: () {
            setState(() {
              _installing = false;
              _completedInstall = false;
              _tab = WelcomeTab.installFlutter;
            });
          },
        );
      case WelcomeTab.installFlutter:
        return installFlutter(
          context,
          onInstall: () async {
            setState(() => _installing = true);

            // Install Flutter on the system.
            await context
                .read<FlutterNotifier>()
                .checkFlutter(context, sdkData);

            setState(() {
              _installing = false;
              _completedInstall = true;
            });
          },
          onContinue: () => setState(() {
            _completedInstall = false;
            _tab = WelcomeTab.installEditor;
          }),
        );
      case WelcomeTab.installEditor:
        return WelcomeInstallEditor(
          onInstall: () async {
            setState(() => _installing = true);

            // None will be skipped and next page will be shown.
            if (_editor.contains(EditorType.none)) {
              setState(() {
                _editor.clear();
                _tab = WelcomeTab.installGit;
              });
            }

            // Installs Android Studio.
            if (_editor.contains(EditorType.androidStudio)) {
              await context
                  .read<AndroidStudioNotifier>()
                  .checkAStudio(context, apiData);
              setState(() => _editor.remove(EditorType.androidStudio));
            }

            // Installs VSCode.
            if (_editor.contains(EditorType.vscode)) {
              await context
                  .read<VSCodeNotifier>()
                  .checkVSCode(context, apiData);
              // After completing, we will remove the item from the list.
              setState(() => _editor.remove(EditorType.vscode));
            }

            setState(() {
              _installing = false;
              _completedInstall = true;
            });
          },
          onEditorTypeChanged: (List<EditorType> val) =>
              setState(() => _editor.addAll(val)),
          isInstalling: _installing,
          doneInstalling: _completedInstall,
          onContinue: () => setState(() {
            _completedInstall = false;
            _tab = WelcomeTab.installGit;
          }),
        );
      case WelcomeTab.installGit:
        return installGit(
          context,
          onInstall: () async {
            setState(() => _installing = true);

            // Install Git on the system.
            await context.read<GitNotifier>().checkGit(context, apiData);

            setState(() {
              _installing = false;
              _completedInstall = true;
            });
          },
          isInstalling: _installing,
          doneInstalling: _completedInstall,
          onContinue: () => setState(() {
            _completedInstall = false;
            _tab = WelcomeTab.installJava;
          }),
        );
      case WelcomeTab.installJava:
        return installJava(
          context,
          onInstall: () async {
            setState(() => _installing = true);

            // Install Java on the system.
            await context.read<JavaNotifier>().checkJava(context, apiData);

            setState(() {
              _installing = false;
              _completedInstall = true;
            });
          },
          onSkip: () => setState(() {
            _installing = false;
            _completedInstall = false;
            _tab = WelcomeTab.restart;
          }),
          onContinue: () async {
            await SharedPref().pref.setString(SPConst.setupTab, 'RESTART');
            setState(() => _tab = WelcomeTab.restart);
          },
          isInstalling: _installing,
          doneInstalling: _completedInstall,
        );
      case WelcomeTab.restart:
        return welcomeRestart(
          context,
          onRestart: () async {
            int _restartSeconds = 5;

            ScaffoldMessenger.of(context).showSnackBar(snackBarTile(context,
                'Your device will restart in $_restartSeconds seconds.',
                type: SnackBarType.warning));

            await SharedPref().pref.setBool(SPConst.completedSetup, true);
            await SharedPref().pref.remove(SPConst.setupTab);

            await Future<void>.delayed(Duration(seconds: _restartSeconds));

            // Restart the system only if it's compiled for release. Prevent
            // restart otherwise.
            if (kReleaseMode) {
              await logger.file(LogTypeTag.info,
                  'Restarting device to continue Flutter setup');
              // Restart the device immediately. There is no need to schedule
              // the restart since we are already having a timer above.
              await shell.run('shutdown /r /f /t');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                snackBarTile(
                  context,
                  'Restarting has been ignored because you are not running a release version of this app. Restart manually instead.',
                  type: SnackBarType.error,
                  duration: Duration(seconds: _restartSeconds),
                ),
              );
            }
          },
        );
    }
  }
}
