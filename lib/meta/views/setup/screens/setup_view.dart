// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/enum.dart';
import 'package:fluttermatic/app/shared_pref.dart';
import 'package:fluttermatic/components/dialog_templates/about/about_us.dart';
import 'package:fluttermatic/components/dialog_templates/flutter/requirements.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/theme.dart';
import 'package:fluttermatic/core/notifiers/notifiers/checks/flutter.dart';
import 'package:fluttermatic/core/notifiers/notifiers/checks/git.dart';
import 'package:fluttermatic/core/notifiers/notifiers/checks/java.dart';
import 'package:fluttermatic/core/notifiers/notifiers/checks/studio.dart';
import 'package:fluttermatic/core/notifiers/notifiers/checks/vsc.dart';
import 'package:fluttermatic/core/notifiers/notifiers/general/theme.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/general/shared_pref.dart';
import 'package:fluttermatic/meta/views/dialogs/documentation.dart';
import 'package:fluttermatic/meta/views/setup/components/header.dart';
import 'package:fluttermatic/meta/views/setup/sections/get_started.dart';
import 'package:fluttermatic/meta/views/setup/sections/install_editor.dart';
import 'package:fluttermatic/meta/views/setup/sections/install_flutter.dart';
import 'package:fluttermatic/meta/views/setup/sections/install_git.dart';
import 'package:fluttermatic/meta/views/setup/sections/install_java.dart';
import 'package:fluttermatic/meta/views/setup/sections/restart.dart';
import 'package:fluttermatic/meta/views/tabs/home.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({Key? key}) : super(key: key);

  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  SetUpTab _tab = SetUpTab.gettingStarted;
  bool _installing = false;
  bool _completedInstall = false;

  // Editor(s) to install.
  final List<EditorType> _editor = <EditorType>[
    EditorType.androidStudio,
    EditorType.vscode,
  ];

  @override
  void initState() {
    if (SharedPref().pref.containsKey(SPConst.setupTab)) {
      setState(() => _tab = SetUpTab.restart);
    } else {
      setState(() => _tab = SetUpTab.gettingStarted);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        ThemeState themeState = ref.watch(themeStateController);
        ThemeNotifier themeNotifier = ref.watch(themeStateController.notifier);

        return Scaffold(
          body: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: <Widget>[
                    createSetUpHeader(_tab, context),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'System Requirements',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: themeState.darkTheme
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                          ),
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
                                builder: (_) => const DocumentationDialog(),
                              );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'Docs & Tutorials',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: themeState.darkTheme
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
                        themeState.darkTheme
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                      ),
                      onPressed: () {
                        themeNotifier.updateTheme(!themeState.darkTheme);
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
                        PageRouteBuilder<Widget>(
                          pageBuilder: (_, __, ___) => const HomeScreen(),
                          transitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _getCurrentPage(BuildContext context) {
    switch (_tab) {
      case SetUpTab.gettingStarted:
        return SetUpGettingStarted(
          onContinue: () {
            setState(() {
              _installing = false;
              _completedInstall = false;
              _tab = SetUpTab.installFlutter;
            });
          },
        );
      case SetUpTab.installFlutter:
        return Consumer(
          builder: (_, ref, __) {
            FlutterNotifier flutterNotifier =
                ref.watch(flutterNotifierController.notifier);

            return installFlutter(
              context,
              onInstall: () async {
                setState(() => _installing = true);

                // Install Flutter on the system.
                await flutterNotifier.checkFlutter();

                setState(() {
                  _installing = false;
                  _completedInstall = true;
                });
              },
              onContinue: () => setState(() {
                _completedInstall = false;
                _tab = SetUpTab.installEditor;
              }),
            );
          },
        );
      case SetUpTab.installEditor:
        return Consumer(
          builder: (_, ref, __) {
            AndroidStudioNotifier androidStudioNotifier =
                ref.watch(androidStudioNotifierController.notifier);

            VSCodeNotifier vscNotifier =
                ref.watch(vscNotifierController.notifier);

            return SetUpInstallEditor(
              onInstall: () async {
                setState(() => _installing = true);

                // None will be skipped and next page will be shown.
                if (_editor.contains(EditorType.none)) {
                  setState(() {
                    _editor.clear();
                    _tab = SetUpTab.installGit;
                  });
                }

                // Installs Android Studio.
                if (_editor.contains(EditorType.androidStudio)) {
                  await androidStudioNotifier.checkAStudio();

                  setState(() => _editor.remove(EditorType.androidStudio));
                }

                // Installs VSCode.
                if (_editor.contains(EditorType.vscode)) {
                  await vscNotifier.checkVSCode();

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
                _tab = SetUpTab.installGit;
              }),
            );
          },
        );
      case SetUpTab.installGit:
        return Consumer(
          builder: (_, ref, __) {
            GitNotifier gitNotifier = ref.watch(gitNotifierController.notifier);

            return installGit(
              context,
              onInstall: () async {
                setState(() => _installing = true);

                // Install Git on the system.
                await gitNotifier.checkGit();

                setState(() {
                  _installing = false;
                  _completedInstall = true;
                });
              },
              isInstalling: _installing,
              doneInstalling: _completedInstall,
              onContinue: () => setState(() {
                _completedInstall = false;
                _tab = SetUpTab.installJava;
              }),
            );
          },
        );
      case SetUpTab.installJava:
        return Consumer(
          builder: (_, ref, __) {
            JavaNotifier javaNotifier =
                ref.watch(javaNotifierController.notifier);

            return installJava(
              context,
              onInstall: () async {
                setState(() => _installing = true);

                // Install Java on the system.
                await javaNotifier.checkJava();

                setState(() {
                  _installing = false;
                  _completedInstall = true;
                });
              },
              onSkip: () => setState(() {
                _installing = false;
                _completedInstall = false;
                _tab = SetUpTab.restart;
              }),
              onContinue: () async {
                await SharedPref().pref.setString(SPConst.setupTab, 'RESTART');
                setState(() => _tab = SetUpTab.restart);
              },
              isInstalling: _installing,
              doneInstalling: _completedInstall,
            );
          },
        );
      case SetUpTab.restart:
        return setUpRestart(
          context,
          onRestart: () async {
            int restartSeconds = 5;

            ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
                context, 'Your device will restart in $restartSeconds seconds.',
                type: SnackBarType.warning));

            await SharedPref().pref.setBool(SPConst.completedSetup, true);
            await SharedPref().pref.remove(SPConst.setupTab);

            await Future<void>.delayed(Duration(seconds: restartSeconds));

            // Restart the system only if it's compiled for release. Prevent
            // restart otherwise for testing purposes.
            if (kReleaseMode) {
              await logger.file(LogTypeTag.info,
                  'Restarting device to continue Flutter setup.');
              // Restart the device immediately. There is no need to schedule
              // the restart since we are already having a timer above.
              await shell.run('shutdown /r /f /t');
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                snackBarTile(
                  context,
                  'Restarting has been ignored because you are not running a release version of this app. Restart manually instead.',
                  type: SnackBarType.error,
                  duration: Duration(seconds: restartSeconds),
                ),
              );
            }
          },
        );
    }
  }
}
