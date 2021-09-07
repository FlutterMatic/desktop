import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/components/dialog_templates/about/about_us.dart';
import 'package:manager/core/libraries/checks.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/sections.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/dialog_templates/flutter/install_flutter.dart';
import 'package:manager/meta/views/home/home.dart';
import 'package:manager/meta/views/welcome/screens/docs_tutorials.dart';
import 'package:manager/components/widgets/ui/snackbar_tile.dart';
import 'package:manager/core/libraries/components.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/meta/utils/shared_pref.dart';
import 'package:provider/provider.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  WelcomeTab _tab = WelcomeTab.gettingStarted;
  int startIndex = 10;
  bool _installing = false;
  bool _completedInstall = false;

  // Editors to install
  List<EditorType> _editor = <EditorType>[
    EditorType.androidStudio,
    EditorType.vscode,
  ];

  @override
  void initState() {
    if (SharedPref().pref.containsKey('Tab')) {
      _tab = WelcomeTab.restart;
    } else {
      _tab = WelcomeTab.gettingStarted;
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
                        child: SingleChildScrollView(
                          child: _getCurrentPage(context),
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
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => FlutterRequirementsDialog(),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'System Requirements',
                            style: TextStyle(
                                fontSize: 12,
                                color: context.read<ThemeChangeNotifier>().isDarkTheme ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                      HSeparators.xSmall(),
                      TextButton(
                        onPressed: kReleaseMode
                            ? () {}
                            : () async {
                                await Navigator.push(context,
                                    MaterialPageRoute<Widget>(builder: (_) => const SystemRequirementsScreen()));
                              },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'Docs & Tutorials',
                            style: TextStyle(
                                fontSize: 12,
                                color: context.read<ThemeChangeNotifier>().isDarkTheme ? Colors.white : Colors.black),
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
                    context.read<ThemeChangeNotifier>().isDarkTheme
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                  ),
                  onPressed: () {
                    context.read<ThemeChangeNotifier>().updateTheme(!context.read<ThemeChangeNotifier>().isDarkTheme);
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
          if (kDebugMode)
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                splashRadius: 1,
                icon: const Icon(Icons.skip_next),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute<Widget>(builder: (_) => const HomeScreen()),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _getCurrentPage(BuildContext context) {
    /// TODO: Add ADB check. This is optional.
    switch (_tab) {
      case WelcomeTab.gettingStarted:
        return WelcomeGettingStarted(
          () => setState(() => _tab = WelcomeTab.installFlutter),
        );
      case WelcomeTab.installFlutter:
        return installFlutter(
          context,
          onInstall: () async {
            if (_completedInstall) {
              setState(() {
                _installing = false;
                _completedInstall = false;
              });
            } else {
              setState(() {
                _installing = true;
              });
              await context.read<FlutterNotifier>().checkFlutter(context, sdkData);
              setState(() {
                _installing = false;
                _completedInstall = false;
              });
            }
          },
          onContinue: () => setState(() => _tab = WelcomeTab.installEditor),
        );
      case WelcomeTab.installEditor:
        return WelcomeInstallEditor(
          onInstall: () async {
            if (_completedInstall) {
              setState(() {
                _installing = false;
                _completedInstall = false;
              });
            } else {
              setState(() {
                _installing = true;
              });
              while (_editor.isNotEmpty) {
                if (_editor.contains(EditorType.none)) {
                  // None will be skipped and next page will be shown.
                  setState(() {
                    _editor.clear();
                    _tab = WelcomeTab.installGit;
                  });
                }
                if (_editor.contains(EditorType.androidStudio)) {
                  // Installs Android Studio.
                  await context.read<AndroidStudioNotifier>().checkAStudio(context, apiData);
                  _editor.remove(EditorType.androidStudio);
                }
                if (_editor.contains(EditorType.vscode)) {
                  // Installs VSCode.
                  await context.read<VSCodeNotifier>().checkVSCode(context, apiData);
                  // After completing, we will remove the item from the list.
                  _editor.remove(EditorType.vscode);
                }
              }
              setState(() {
                _installing = false;
                _completedInstall = false;
              });
            }
          },
          onEditorTypeChanged: (List<EditorType> val) {
            setState(() => _editor = val);
            print(_editor);
          },
          isInstalling: _installing,
          doneInstalling: _completedInstall,
          onContinue: () => setState(() => _tab = WelcomeTab.installGit),
        );
      case WelcomeTab.installGit:
        return installGit(
          context,
          onInstall: () async {
            if (_completedInstall) {
              setState(() {
                _installing = false;
                _completedInstall = false;
              });
            } else {
              setState(() {
                _installing = true;
              });
              await context.read<GitNotifier>().checkGit(context, apiData);
              setState(() {
                _installing = false;
                _completedInstall = false;
              });
            }
          },
          isInstalling: _installing,
          doneInstalling: _completedInstall,
          onContinue: () => setState(() => _tab = WelcomeTab.installJava),
        );
      case WelcomeTab.installJava:
        return installJava(
          context,
          onInstall: () async {
            if (_completedInstall) {
              setState(() {
                _installing = false;
                _completedInstall = false;
              });
            } else {
              setState(() {
                _installing = true;
              });
              await context.read<JavaNotifier>().checkJava(context, apiData);
              setState(() {
                _installing = false;
                _completedInstall = false;
              });
            }
          },
          onSkip: () => setState(() {
            _installing = false;
            _completedInstall = false;
            _tab = WelcomeTab.restart;
          }),
          onContinue: () async {
            await SharedPref().pref.setString('Tab', 'restart');
            setState(() => _tab = WelcomeTab.restart);
          },
          isInstalling: _installing,
          doneInstalling: _completedInstall,
        );
      case WelcomeTab.restart:
        return welcomeRestart(
          context,
          timer: startIndex == 0
              ? 'Restarting'
              : startIndex < 10
                  ? startIndex.toString()
                  : null,
          onRestart: () async {
            int _restartSeconds = 10;

            Timer.periodic(const Duration(milliseconds: 750), (Timer timer) {
              if (startIndex == 0) {
                setState(() {
                  timer.cancel();
                });
              } else {
                setState(() {
                  startIndex--;
                });
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
                context, 'Your device will restart in $_restartSeconds seconds.',
                type: SnackBarType.warning));
            await SharedPref().pref.setBool('All_Checked', true);
            await SharedPref().pref.remove('Tab');

            // Restart the system only if it's compiled for release. Prevent
            // restart otherwise.
            if (kReleaseMode) {
              await logger.file(LogTypeTag.info, 'Restarting device to continue Flutter setup');
              // Restart the device immediately. There is no need to schedule
              // the restart since we are already having a timer above.
              await shell.run('shutdown /r /f /t $_restartSeconds');
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
