import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/core/libraries/checks.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/sections.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/ui/snackbar_tile.dart';
import 'package:manager/meta/utils/shared_pref.dart';
import 'package:manager/core/libraries/components.dart';
import 'package:manager/meta/views/welcome/screens/requirements.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  WelcomeTab _tab = WelcomeTab.gettingStarted;
  Progress progress = Progress.none;

  bool _installing = false;
  bool _completedInstall = false;

  // Editors
  EditorType _editor = EditorType.both;

  @override
  void initState() {
    _tab = SharedPref().prefs.containsKey('Tab') ? WelcomeTab.restart : WelcomeTab.gettingStarted;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _currentTheme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: <Widget>[
                createWelcomeHeader(_currentTheme, _tab, context),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SizedBox(
                      width: 415,
                      child: Center(
                        child: SingleChildScrollView(
                          child: _getCurrentPage(context, _currentTheme),
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
                        // onPressed: () => showDialog(
                        //   context: context,
                        //   // builder: (_) => const SystemRequirementsDialog(),
                        //   builder: (_) => InstallFlutterDialog(),
                        // ),
                        onPressed: () async {
                          await Navigator.of(context).push(MaterialPageRoute<void>(
                            builder: (_) => const SystemRequirementsScreen(),
                          ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'System Requirements',
                            style: _currentTheme.textTheme.bodyText2!.copyWith(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      TextButton(
                        onPressed: () {},
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'Docs & Tutorials',
                            style: _currentTheme.textTheme.bodyText2!.copyWith(fontSize: 12),
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
            bottom: 29,
            right: 20,
            child: Tooltip(
              padding: const EdgeInsets.all(5),
              message:
                  'Version: ${SharedPref().prefs.getString('App_Version')} (${SharedPref().prefs.getString('App_Build')!.toUpperCase()})\n$osName - $osVersion',
              child: const Icon(Icons.info_outline_rounded),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 60,
            child: IconButton(
              splashRadius: 1,
              icon: Icon(
                context.read<ThemeChangeNotifier>().isDarkTheme ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              ),
              onPressed: () {
                context.read<ThemeChangeNotifier>().updateTheme(
                      !context.read<ThemeChangeNotifier>().isDarkTheme,
                    );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _getCurrentPage(BuildContext context, ThemeData _currentTheme) {
    /// TODO: Add ADB check.
    switch (_tab) {
      case WelcomeTab.gettingStarted:
        return WelcomeGettingStarted(
          () => setState(() => _tab = WelcomeTab.installFlutter),
        );
      case WelcomeTab.installFlutter:
        return installFlutter(
          context,
          onInstall: () async {
            // if (context.read<SpaceCheck>().lowDriveSpace &&
            //     context.read<SpaceCheck>().drive == 'C') {
            //   await showDialog(
            //     context: context,
            //     barrierDismissible: false,
            //     builder: (_) => const LowDriveSpaceDialog(),
            //   );
            // }
            if (_completedInstall) {
              setState(() {
                _installing = false;
                _completedInstall = false;
                progress = Progress.done;
              });
            } else {
              setState(() {
                _installing = true;
                progress = Progress.started;
              });
              await context.read<FlutterNotifier>().checkFlutter(context, sdkData);
              setState(() {
                _installing = false;
                _completedInstall = false;
                progress = Progress.done;
              });
            }
          },
          // progress: _tab == WelcomeTab.installEditor
          //     ? progress
          //     : context.read<DownloadNotifier>().progress,
          onCancel: () {},
          onContinue: () {
            setState(() {
              _tab = WelcomeTab.installEditor;
            });
          },
        );
      case WelcomeTab.installEditor:
        return installEditor(
          context,
          onInstall: () async {
            if (_completedInstall) {
              setState(() {
                _installing = false;
                _completedInstall = false;
                progress = Progress.done;
              });
            } else {
              setState(() {
                _installing = true;
                progress = Progress.started;
              });
              switch (_editor.index) {
                case 0:
                  await context.read<VSCodeNotifier>().checkVSCode(context, apiData);
                  break;
                case 1:
                  await context.read<AndroidStudioNotifier>().checkAStudio(context, apiData);
                  break;
                default:
                  await context.read<VSCodeNotifier>().checkVSCode(context, apiData);
                  await context.read<AndroidStudioNotifier>().checkAStudio(context, apiData);
              }
            }
            setState(() {
              _installing = false;
              _completedInstall = false;
              progress = Progress.done;
            });
          },
          onCancel: () {},
          selectedType: _editor,
          onEditorTypeChanged: (EditorType val) => setState(() => _editor = val),
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
                progress = Progress.done;
              });
            } else {
              setState(() {
                _installing = true;
                progress = Progress.started;
              });
              await context.read<GitNotifier>().checkGit(context, apiData);
              setState(() {
                _installing = false;
                _completedInstall = false;
                progress = Progress.done;
              });
            }
          },
          onCancel: () {},
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
                progress = Progress.done;
              });
            } else {
              setState(() {
                _installing = true;
                progress = Progress.started;
              });
              await context.read<JavaNotifier>().checkJava(context, apiData);
              setState(() {
                _installing = false;
                _completedInstall = false;
                progress = Progress.done;
              });
            }
          },
          onSkip: () => setState(() {
            _installing = false;
            _completedInstall = false;
            _tab = WelcomeTab.restart;
          }),
          onContinue: () async {
            await SharedPref().prefs.setString('Tab', 'restart');
            setState(() => _tab = WelcomeTab.restart);
          },
          isInstalling: _installing,
          doneInstalling: _completedInstall,
        );
      case WelcomeTab.restart:
        return welcomeRestart(
          context,
          onRestart: () async {
            int _restartSeconds = 15;

            ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
                context, 'Your device will restart in less than $_restartSeconds seconds.',
                type: SnackBarType.warning));

            await Future<void>.delayed(Duration(seconds: _restartSeconds));

            /// Restart the system only if it's compiled for release. Prevent
            /// restart on debugging.
            if (kReleaseMode) {
              await SharedPref().prefs.setBool('All_Checked', true);
              await SharedPref().prefs.remove('Tab');
              await logger.file(LogTypeTag.info, 'Restarting device to continue Flutter setup');
              await shell.run('shutdown /r /f /t $_restartSeconds');
            } else {
              await SharedPref().prefs.setBool('All_Checked', true);
              await SharedPref().prefs.remove('Tab');
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
