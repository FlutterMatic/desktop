import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/core/libraries/checks.dart';
import 'package:manager/core/libraries/sections.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/ui/snackbar_tile.dart';
import 'package:manager/meta/views/screens/system_requirements.dart';
import 'package:manager/meta/views/welcome/sections/install_editor.dart';
import 'package:manager/meta/views/welcome/components/header.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  WelcomeTab _tab = WelcomeTab.GETTING_STARTED;

  bool _installing = false;
  bool _completedInstall = false;

  double _totalInstalled = 0;
  final double _totalInstallSize = 1600000000;

  // Editors
  EditorType _editor = EditorType.BOTH;

  @override
  Widget build(BuildContext context) {
    ThemeData _currentTheme = Theme.of(context);

    /// TODO: Fix animation for header. Like make it smooth sliding while changing the tab.
    return Scaffold(
      body: Padding(
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
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<Widget>(
                        builder: (_) => const SystemRequirementsScreen(),
                      ),
                    ),
                    // TODO: Create system requirements page.
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
                    // TODO: Create docs & tutorials page.
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
          () async {
            if (_completedInstall) {
              setState(() {
                _installing = false;
                _completedInstall = false;
                _tab = WelcomeTab.INSTALL_EDITOR;
              });
            } else {
              setState(() => _installing = true);
              await context
                  .read<FlutterChangeNotifier>()
                  .checkFlutter(context, sdkData);
              setState(() {
                _installing = false;
                _completedInstall = false;
                _tab = WelcomeTab.INSTALL_EDITOR;
              });
            }
          },
          isInstalling: _installing,
          doneInstalling: _completedInstall,
        );
      case WelcomeTab.INSTALL_EDITOR:
        return InstallEditor(
          onInstall: () {
            if (_completedInstall) {
              setState(() {
                _installing = false;
                _completedInstall = false;
                _tab = WelcomeTab.INSTALL_GIT;
              });
            } else {
              setState(() => _installing = true);
              Timer.periodic(const Duration(microseconds: 2), (Timer timer) {
                if (_totalInstalled < _totalInstallSize) {
                  setState(() => _totalInstalled += 10000);
                } else {
                  timer.cancel();
                  setState(() {
                    _totalInstalled = 0;
                    _completedInstall = true;
                    _installing = false;
                  });
                }
              });
            }
          },
          selectedType: _editor,
          onEditorTypeChanged: (EditorType val) =>
              setState(() => _editor = val),
          isInstalling: _installing,
          doneInstalling: _completedInstall,
        );
      case WelcomeTab.INSTALL_GIT:
        return installGit(
          context,
          () {
            if (_completedInstall) {
              setState(() {
                _installing = false;
                _completedInstall = false;
                _tab = WelcomeTab.INSTALL_JAVA;
              });
            } else {
              setState(() => _installing = true);
              Timer.periodic(
                const Duration(microseconds: 2),
                (Timer timer) {
                  if (_totalInstalled < _totalInstallSize) {
                    setState(() => _totalInstalled += 10000);
                  } else {
                    timer.cancel();
                    setState(
                      () {
                        _totalInstalled = 0;
                        _completedInstall = true;
                        _installing = false;
                      },
                    );
                  }
                },
              );
            }
          },
          isInstalling: _installing,
          doneInstalling: _completedInstall,
        );
      case WelcomeTab.INSTALL_JAVA:
        return installJava(
          context,
          () {
            if (_completedInstall) {
              setState(() {
                _installing = false;
                _completedInstall = false;
                _tab = WelcomeTab.RESTART;
              });
            } else {
              setState(() => _installing = true);
              Timer.periodic(const Duration(microseconds: 2), (Timer timer) {
                if (_totalInstalled < _totalInstallSize) {
                  setState(() => _totalInstalled += 10000);
                } else {
                  timer.cancel();
                  setState(() {
                    _totalInstalled = 0;
                    _completedInstall = true;
                    _installing = false;
                  });
                }
              });
            }
          },
          () => setState(() {
            _installing = false;
            _completedInstall = false;
            _tab = WelcomeTab.RESTART;
          }),
          isInstalling: _installing,
          doneInstalling: _completedInstall,
        );
      case WelcomeTab.RESTART:
        return welcomeRestart(context, () async {
          int _restartSeconds = 5;
          await logger.file(
              LogTypeTag.INFO, 'Restarting device to continue Flutter setup');

          ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
              'Your device will restart in less than $_restartSeconds seconds.',
              type: SnackBarType.warning));

          await Future<void>.delayed(const Duration(seconds: 5));

          /// Restart the system only if it's compiled for release. Prevent
          /// restart on debugging.
          if (kReleaseMode) {
            await shell.run('shutdown /r /f');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              snackBarTile(
                  'Restarting has been ignored because you are not running a release version of this app. Restart manually instead.',
                  type: SnackBarType.error),
            );
          }
        });
    }
  }
}
