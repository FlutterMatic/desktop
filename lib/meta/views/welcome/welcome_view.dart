import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manager/meta/views/welcome/components/progress_indicator.dart';
import 'dart:async';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  _CurrentTab _tab = _CurrentTab.Getting_Started;

  bool _installing = false;
  bool _completedInstall = false;

  double _totalInstalled = 0;
  final double _totalInstallSize = 1600000000;

  // Editors
  _EditorType _editor = _EditorType.Both;

  @override
  Widget build(BuildContext context) {
    ThemeData _currentTheme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: <Widget>[
            _createHeader(_currentTheme, _tab),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  width: 415,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_tab == _CurrentTab.Getting_Started)
                        _gettingStarted(() =>
                            setState(() => _tab = _CurrentTab.Install_Flutter)),
                      if (_tab == _CurrentTab.Install_Flutter)
                        _installFlutter(
                          () {
                            if (_completedInstall) {
                              setState(() {
                                _installing = false;
                                _completedInstall = false;
                                _tab = _CurrentTab.Install_Editor;
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
                      if (_tab == _CurrentTab.Install_Editor)
                        _installEditor(
                          () {
                            if (_completedInstall) {
                              setState(() {
                                _installing = false;
                                _completedInstall = false;
                                _tab = _CurrentTab.Install_Git;
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
                      if (_tab == _CurrentTab.Install_Git)
                        _installGit(
                          () {
                            if (_completedInstall) {
                              setState(() {
                                _installing = false;
                                _completedInstall = false;
                                _tab = _CurrentTab.Install_Java;
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
                      if (_tab == _CurrentTab.Install_Java)
                        _installJava(
                          () {
                            if (_completedInstall) {
                              setState(() {
                                _installing = false;
                                _completedInstall = false;
                                _tab = _CurrentTab.Restart;
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
                            _tab = _CurrentTab.Restart;
                          }),
                          theme: _currentTheme,
                          isInstalling: _installing,
                          totalInstalled: _totalInstalled,
                          completedSize: _totalInstallSize,
                          doneInstalling: _completedInstall,
                        ),
                      if (_tab == _CurrentTab.Restart) _restart(() {}),
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

enum _CurrentTab {
  Getting_Started,
  Install_Flutter,
  Install_Editor,
  Install_Git,
  Install_Java,
  Restart,
}

Widget _createHeader(ThemeData theme, _CurrentTab tab) {
  Widget _title(String title, _CurrentTab tileTab) {
    return Expanded(
      child: tab == tileTab
          ? AnimatedContainer(
              duration: const Duration(seconds: 5),
              child: Column(
                children: [
                  Text(title),
                  const SizedBox(height: 20),
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: theme.textTheme.headline1!.color,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  return Padding(
    padding: const EdgeInsets.only(top: 30),
    child: Center(
      child: SizedBox(
        width: 800,
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Container(
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xff757575),
              ),
            ),
            Row(
              children: [
                _title('Getting Started', _CurrentTab.Getting_Started),
                _title('Install Flutter', _CurrentTab.Install_Flutter),
                _title('Install Editor', _CurrentTab.Install_Editor),
                _title('Install Git', _CurrentTab.Install_Git),
                _title('Install Java', _CurrentTab.Install_Java),
                _title('Restart', _CurrentTab.Restart),
              ],
            )
          ],
        ),
      ),
    ),
  );
}

Widget _header(String iconPath, String title, String description,
    {double iconHeight = 30}) {
  return Column(
    children: [
      SvgPicture.asset(iconPath, height: iconHeight),
      const SizedBox(height: 20),
      Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
      ),
      const SizedBox(height: 25),
      Text(
        description,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16),
      ),
    ],
  );
}

Widget _button(String title, Function onPressed, {bool disabled = false}) {
  return SizedBox(
    width: 210,
    height: 50,
    child: IgnorePointer(
      ignoring: disabled,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: disabled ? 0.5 : 1,
        child: MaterialButton(
          height: 58,
          minWidth: 270,
          color: const Color(0xffCDD4DD),
          onPressed: onPressed as Function()?,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_rounded, size: 18),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Tabs Contents

/// -- Getting Started --
Widget _gettingStarted(Function onContinue) {
  return Column(
    children: [
      _header(
        'assets/images/logos/flutter.svg',
        'Install Flutter',
        'Welcome to the Flutter installer. You will be guided through the steps necessary to setup and install Flutter in your computer.',
        iconHeight: 50,
      ),
      const SizedBox(height: 50),
      _button(
        'Continue',
        onContinue,
      ),
    ],
  );
}

// -- Install Flutter --
Widget _installFlutter(
  Function onInstall, {
  required bool doneInstalling,
  required bool isInstalling,
  required double completedSize,
  required double totalSize,
}) {
  return Column(
    children: [
      _header(
        'assets/images/logos/flutter.svg',
        'Install Flutter',
        'You will need to install Flutter in your machine to start using Flutter.',
      ),
      const SizedBox(height: 50),
      if (!doneInstalling)
        installProgressIndicator(
          totalInstalled: completedSize,
          totalSize: totalSize,
          objectSize: '1.8 GB',
          disabled: !isInstalling,
        )
      else
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xff363D4D),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_rounded, color: Color(0xff07C2A3)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Flutter Installed',
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text(
                        'Flutter was installed successfully on your machine. Continue to the next step.',
                        style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: 50),
      _button(doneInstalling ? 'Next' : 'Install', onInstall,
          disabled: isInstalling),
    ],
  );
}

// -- Install Editor --
enum _EditorType {
  VS_Code,
  Android_Studio,
  Both,
}
Widget _installEditor(
  Function onInstall, {
  required _EditorType selectedType,
  required Function(_EditorType) onEditorTypeChanged,
  required bool isInstalling,
  required bool doneInstalling,
  required double completedSize,
  required double totalInstalled,
}) {
  Widget _selectEditor(
      {required String name, required _EditorType type, required Widget icon}) {
    bool _selected = selectedType == type;
    return Expanded(
      child: SizedBox(
        height: 120,
        width: 120,
        child: MaterialButton(
          color: const Color(0xff4C5362),
          onPressed: () => onEditorTypeChanged(type),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: _selected ? const Color(0xff07C2A3) : Colors.transparent,
              width: _selected ? 2 : 0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Column(
              children: [
                Expanded(child: icon),
                Text(
                  name,
                  style: const TextStyle(color: Color(0xffCDD4DD)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  return Column(
    children: [
      _header(
        'assets/images/icons/editor.svg',
        'Install Editor',
        'You will need to install the Flutter Editor to start using Flutter.',
      ),
      const SizedBox(height: 30),
      AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isInstalling ? 0.2 : 1,
        child: IgnorePointer(
          ignoring: isInstalling || doneInstalling,
          child: Row(
            children: [
              _selectEditor(
                icon:
                    SvgPicture.asset('assets/images/logos/android_studio.svg'),
                name: 'Android Studio',
                type: _EditorType.Android_Studio,
              ),
              const SizedBox(width: 15),
              _selectEditor(
                icon: SvgPicture.asset('assets/images/logos/vs_code.svg'),
                name: 'VS Code',
                type: _EditorType.VS_Code,
              ),
              const SizedBox(width: 15),
              _selectEditor(
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset('assets/images/logos/android_studio.svg',
                        height: 30),
                    const SizedBox(width: 10),
                    Container(width: 1, height: 20, color: Colors.white10),
                    const SizedBox(width: 10),
                    SvgPicture.asset('assets/images/logos/vs_code.svg',
                        height: 30),
                  ],
                ),
                name: 'Both',
                type: _EditorType.Both,
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 30),
      if (!doneInstalling)
        installProgressIndicator(
          disabled: !isInstalling,
          totalInstalled: totalInstalled,
          totalSize: completedSize,
          objectSize: '3.2 GB',
        )
      else
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xff363D4D),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_rounded, color: Color(0xff07C2A3)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Editor${selectedType == _EditorType.Both ? 's' : ''} Installed',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                        'You have successfully installed ${selectedType == _EditorType.Android_Studio ? 'Android Studio' : selectedType == _EditorType.VS_Code ? 'Visual Studio Code' : 'Android Studio & Visual Studio Code'}.',
                        style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: 30),
      _button(doneInstalling ? 'Next' : 'Install', onInstall,
          disabled: isInstalling),
    ],
  );
}

// -- Install Git --
Widget _installGit(
  Function onInstall, {
  required bool isInstalling,
  required bool doneInstalling,
  required double completedSize,
  required double totalInstalled,
}) {
  return Column(
    children: [
      _header(
        'assets/images/logos/git.svg',
        'Install Git',
        'Flutter relies on Git to get and install dependencies and other tools.',
      ),
      const SizedBox(height: 30),
      if (!doneInstalling)
        installProgressIndicator(
          disabled: !isInstalling,
          totalInstalled: totalInstalled,
          totalSize: completedSize,
          objectSize: '3.2 GB',
        )
      else
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xff363D4D),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_rounded, color: Color(0xff07C2A3)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Git Installed', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text(
                        'You have successfully installed Git. Click next to continue.',
                        style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: 30),
      _button(doneInstalling ? 'Next' : 'Install', onInstall,
          disabled: isInstalling),
    ],
  );
}

// -- Install Java --
Widget _installJava(
  Function onInstall,
  Function onSkip, {
  required ThemeData theme,
  required bool isInstalling,
  required bool doneInstalling,
  required double completedSize,
  required double totalInstalled,
}) {
  return Column(
    children: [
      _header(
        'assets/images/logos/java.svg',
        'Install Java',
        'Java is sometimes needed in Flutter development. However you can skip if you do not want to install Java.',
      ),
      const SizedBox(height: 50),
      if (!doneInstalling)
        installProgressIndicator(
          disabled: !isInstalling,
          totalInstalled: totalInstalled,
          totalSize: completedSize,
          objectSize: '3.2 GB',
        )
      else
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xff363D4D),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_rounded, color: Color(0xff07C2A3)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Java Installed',
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text(
                        'You have successfully installed Java. Click next to wrap up.',
                        style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: 50),
      _button(doneInstalling ? 'Next' : 'Install', onInstall,
          disabled: isInstalling),
      const SizedBox(height: 20),
      if (!doneInstalling && !isInstalling)
        TextButton(
          onPressed: onSkip as Function(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Skip',
              style: theme.textTheme.bodyText2!.copyWith(fontSize: 12),
            ),
          ),
        ),
    ],
  );
}

// -- Restart --
Widget _restart(Function onRestart) {
  return Column(
    children: [
      _header(
        'assets/images/icons/confetti.svg',
        'Congrats',
        'All set! You will need to restart your computer to start using Flutter.',
      ),
      const SizedBox(height: 30),
      Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xff363D4D),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Documentation', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            const Text(
                'Read the official Flutter documentation or check our documentation for how to use this app.',
                style: TextStyle(fontSize: 13)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: MaterialButton(
                    height: 50,
                    color: const Color(0xff4C5362),
                    onPressed: () {},
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Flutter Documentation',
                        style: TextStyle(color: Color(0xffCDD4DD))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MaterialButton(
                    height: 50,
                    color: const Color(0xff4C5362),
                    onPressed: () {},
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Our Documentation',
                      style: TextStyle(color: Color(0xffCDD4DD)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 30),
      _button('Restart', onRestart),
    ],
  );
}
