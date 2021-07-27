import 'package:flutter/material.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/meta/views/welcome/components/header.dart';
import 'package:manager/meta/views/welcome/sections/get_started.dart';
import 'package:manager/meta/views/welcome/sections/install_editor.dart';
import 'package:manager/meta/views/welcome/sections/install_flutter.dart';
import 'package:manager/meta/views/welcome/sections/install_git.dart';
import 'package:manager/meta/views/welcome/sections/install_java.dart';
import 'package:manager/meta/views/welcome/sections/restart.dart';
import 'dart:async';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  WelcomeTab _tab = WelcomeTab.Getting_Started;

  bool _installing = false;
  bool _completedInstall = false;

  double _totalInstalled = 0;
  final double _totalInstallSize = 1600000000;

  // Editors
  EditorType _editor = EditorType.Both;

  @override
  Widget build(BuildContext context) {
    ThemeData _currentTheme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: <Widget>[
            createWelcomeHeader(_currentTheme, _tab),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  width: 415,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_tab == WelcomeTab.Getting_Started)
                        welcomeGettingStarted(() =>
                            setState(() => _tab = WelcomeTab.Install_Flutter)),
                      if (_tab == WelcomeTab.Install_Flutter)
                        installFlutter(
                          () {
                            if (_completedInstall) {
                              setState(() {
                                _installing = false;
                                _completedInstall = false;
                                _tab = WelcomeTab.Install_Editor;
                              });
                            } else {
                              setState(() => _installing = true);
                              Timer.periodic(const Duration(microseconds: 2),
                                  (timer) {
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
                          completedSize: _totalInstalled,
                          totalSize: _totalInstallSize,
                          isInstalling: _installing,
                          doneInstalling: _completedInstall,
                        ),
                      if (_tab == WelcomeTab.Install_Editor)
                        installEditor(
                          () {
                            if (_completedInstall) {
                              setState(() {
                                _installing = false;
                                _completedInstall = false;
                                _tab = WelcomeTab.Install_Git;
                              });
                            } else {
                              setState(() => _installing = true);
                              Timer.periodic(const Duration(microseconds: 2),
                                  (timer) {
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
                          onEditorTypeChanged: (val) =>
                              setState(() => _editor = val),
                          isInstalling: _installing,
                          totalInstalled: _totalInstalled,
                          completedSize: _totalInstallSize,
                          doneInstalling: _completedInstall,
                        ),
                      if (_tab == WelcomeTab.Install_Git)
                        installGit(
                          () {
                            if (_completedInstall) {
                              setState(() {
                                _installing = false;
                                _completedInstall = false;
                                _tab = WelcomeTab.Install_Java;
                              });
                            } else {
                              setState(() => _installing = true);
                              Timer.periodic(const Duration(microseconds: 2),
                                  (timer) {
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
                          isInstalling: _installing,
                          totalInstalled: _totalInstalled,
                          completedSize: _totalInstallSize,
                          doneInstalling: _completedInstall,
                        ),
                      if (_tab == WelcomeTab.Install_Java)
                        installJava(
                          () {
                            if (_completedInstall) {
                              setState(() {
                                _installing = false;
                                _completedInstall = false;
                                _tab = WelcomeTab.Restart;
                              });
                            } else {
                              setState(() => _installing = true);
                              Timer.periodic(const Duration(microseconds: 2),
                                  (timer) {
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
                            _tab = WelcomeTab.Restart;
                          }),
                          theme: _currentTheme,
                          isInstalling: _installing,
                          totalInstalled: _totalInstalled,
                          completedSize: _totalInstallSize,
                          doneInstalling: _completedInstall,
                        ),
                      if (_tab == WelcomeTab.Restart) welcomeRestart(() {}),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {},
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
}