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
import 'package:manager/meta/views/welcome/screens/system_requirements.dart';
import 'package:manager/core/libraries/components.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  WelcomeTab _tab = WelcomeTab.GETTING_STARTED;
  Progress progress = Progress.NONE;

  bool _installing = false;
  bool _completedInstall = false;

  // Editors
  EditorType _editor = EditorType.BOTH;

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
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const SystemRequirementsDialog(),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'System Requirements',
                            style: _currentTheme.textTheme.bodyText2!
                                .copyWith(fontSize: 12),
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
                            style: _currentTheme.textTheme.bodyText2!
                                .copyWith(fontSize: 12),
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
              message: 'Alpha 0.0.1\n$osName - $osVersion',
              child: const Icon(
                Icons.info_outline_rounded,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 60,
            child: IconButton(
              splashRadius: 1,
              icon: Icon(
                context.read<ThemeChangeNotifier>().isDarkTheme
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
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
      case WelcomeTab.GETTING_STARTED:
        return WelcomeGettingStarted(
          () => setState(() => _tab = WelcomeTab.INSTALL_FLUTTER),
        );
      case WelcomeTab.INSTALL_FLUTTER:
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
                progress = Progress.DONE;
              });
            } else {
              setState(() {
                _installing = true;
                progress = Progress.STARTED;
              });
              await context
                  .read<FlutterNotifier>()
                  .checkFlutter(context, sdkData);
              setState(() {
                _installing = false;
                _completedInstall = false;
                progress = Progress.DONE;
              });
            }
          },
          // progress: _tab == WelcomeTab.INSTALL_EDITOR
          //     ? progress
          //     : context.read<DownloadNotifier>().progress,
          onCancel: () {},
          onContinue: () {
            setState(() {
              _tab = WelcomeTab.INSTALL_EDITOR;
            });
          },
        );
      case WelcomeTab.INSTALL_EDITOR:
        return installEditor(
          context,
          onInstall: () async {
            if (_completedInstall) {
              setState(() {
                _installing = false;
                _completedInstall = false;
                progress = Progress.DONE;
              });
            } else {
              setState(() {
                _installing = true;
                progress = Progress.STARTED;
              });
              switch (_editor.index) {
                case 0:
                  await context
                      .read<VSCodeNotifier>()
                      .checkVSCode(context, apiData);
                  break;
                case 1:
                  await context
                      .read<AndroidStudioNotifier>()
                      .checkAStudio(context, apiData);
                  break;
                default:
                  await context
                      .read<VSCodeNotifier>()
                      .checkVSCode(context, apiData);
                  await context
                      .read<AndroidStudioNotifier>()
                      .checkAStudio(context, apiData);
              }
            }
            setState(() {
              _installing = false;
              _completedInstall = false;
              progress = Progress.DONE;
            });
          },
          onCancel: () {},
          selectedType: _editor,
          onEditorTypeChanged: (EditorType val) =>
              setState(() => _editor = val),
          isInstalling: _installing,
          doneInstalling: _completedInstall,
          onContinue: () => setState(() => _tab = WelcomeTab.INSTALL_GIT),
        );
      case WelcomeTab.INSTALL_GIT:
        return installGit(
          context,
          onInstall: () async {
            if (_completedInstall) {
              setState(() {
                _installing = false;
                _completedInstall = false;
                progress = Progress.DONE;
              });
            } else {
              setState(() {
                _installing = true;
                progress = Progress.STARTED;
              });
              await context.read<GitNotifier>().checkGit(context, apiData);
              setState(() {
                _installing = false;
                _completedInstall = false;
                progress = Progress.DONE;
              });
            }
          },
          onCancel: () {},
          isInstalling: _installing,
          doneInstalling: _completedInstall,
          onContinue: () => setState(() => _tab = WelcomeTab.INSTALL_JAVA),
        );
      case WelcomeTab.INSTALL_JAVA:
        return installJava(
          context,
          onInstall: () async {
            if (_completedInstall) {
              setState(() {
                _installing = false;
                _completedInstall = false;
                progress = Progress.DONE;
              });
            } else {
              setState(() {
                _installing = true;
                progress = Progress.STARTED;
              });
              await context.read<JavaNotifier>().checkJava(context, apiData);
              setState(() {
                _installing = false;
                _completedInstall = false;
                progress = Progress.DONE;
              });
            }
          },
          onSkip: () => setState(() {
            _installing = false;
            _completedInstall = false;
            _tab = WelcomeTab.RESTART;
          }),
          onContinue: () => setState(() => _tab = WelcomeTab.RESTART),
          isInstalling: _installing,
          doneInstalling: _completedInstall,
        );
      case WelcomeTab.RESTART:
        return welcomeRestart(
          context,
          onRestart: () async {
            int _restartSeconds = 5;

            ScaffoldMessenger.of(context).showSnackBar(snackBarTile(context,
                'Your device will restart in less than $_restartSeconds seconds.',
                type: SnackBarType.warning));

            await Future<void>.delayed(Duration(seconds: _restartSeconds));

            /// Restart the system only if it's compiled for release. Prevent
            /// restart on debugging.
            if (kReleaseMode) {
              await logger.file(LogTypeTag.INFO,
                  'Restarting device to continue Flutter setup');
              await shell.run('shutdown /r /f');
            } else {
              await SharedPref().prefs.setBool('All Checked', true);
              ScaffoldMessenger.of(context).showSnackBar(
                snackBarTile(
                  context,
                  'Restarting has been ignored because you are not running a release version of this app. Restart manually instead.',
                  type: SnackBarType.error,
                  duration: const Duration(seconds: 15),
                ),
              );
            }
          },
        );
    }
  }
}
