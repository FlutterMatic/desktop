import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/buttons/rectangle_button.dart';
import 'package:manager/components/widgets/ui/warning_widget.dart';
import 'package:manager/core/libraries/components.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/checks.dart';
import 'package:provider/provider.dart';

class WelcomeInstallEditor extends StatefulWidget {
  final VoidCallback onInstall;
  final VoidCallback onContinue;
  final Function(List<EditorType>) onEditorTypeChanged;
  final bool isInstalling;
  final bool doneInstalling;

  const WelcomeInstallEditor({
    Key? key,
    required this.onInstall,
    required this.onContinue,
    required this.onEditorTypeChanged,
    required this.isInstalling,
    required this.doneInstalling,
  }) : super(key: key);

  @override
  _WelcomeInstallEditorState createState() => _WelcomeInstallEditorState();
}

class _WelcomeInstallEditorState extends State<WelcomeInstallEditor> {
  bool _showEditorSelector = true;

  List<EditorType> _editorTypes = <EditorType>[
    EditorType.androidStudio,
    EditorType.vscode,
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer2<VSCodeNotifier, AndroidStudioNotifier>(
      builder: (BuildContext context, VSCodeNotifier vsCodeNotifier,
          AndroidStudioNotifier androidStudioNotifier, _) {
        Progress _getActivityProgress() {
          return Progress.done;
          // TODO: Fixe progress issue.
          // if (_editorTypes.contains(EditorType.vscode) &&
          //     _editorTypes.contains(EditorType.androidStudio)) {
          //   if (vsCodeNotifier.progress != Progress.none &&
          //       vsCodeNotifier.progress != Progress.done) {
          //     return vsCodeNotifier.progress;
          //   } else {
          //     return androidStudioNotifier.progress;
          //   }
          // } else {
          //   if (_editorTypes.contains(EditorType.vscode)) {
          //     return vsCodeNotifier.progress;
          //   } else {
          //     return androidStudioNotifier.progress;
          //   }
          // }
        }

        return Column(
          children: <Widget>[
            welcomeHeaderTitle(
              Assets.editor,
              'Install Editor',
              'You will need to install the Flutter Editor to start using Flutter.',
            ),
            if (_editorTypes.contains(EditorType.none))
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: informationWidget(
                  'We recommend selecting an editor. If an editor is already installed, select it and we will check if you have all necessary tools for it available.',
                  type: InformationType.warning,
                ),
              ),
            VSeparators.normal(),
            if (_showEditorSelector)
              Row(
                children: <Widget>[
                  _selectEditor(
                    context,
                    icon: SvgPicture.asset(Assets.vscode),
                    name: 'VS Code',
                    type: EditorType.vscode,
                    onEditorTypeChanged: (EditorType val) {
                      if (_editorTypes.contains(EditorType.none)) {
                        setState(() =>
                            _editorTypes = <EditorType>[EditorType.vscode]);
                      } else {
                        if (_editorTypes.contains(EditorType.vscode)) {
                          if (_editorTypes.length == 1) {
                            setState(() =>
                                _editorTypes = <EditorType>[EditorType.none]);
                          } else {
                            setState(
                                () => _editorTypes.remove(EditorType.vscode));
                          }
                        } else {
                          setState(() => _editorTypes.add(EditorType.vscode));
                        }
                      }
                      widget.onEditorTypeChanged(_editorTypes);
                    },
                    installation: vsCodeNotifier.progress != Progress.none ||
                        androidStudioNotifier.progress != Progress.none,
                    isSelected: _editorTypes.contains(EditorType.vscode),
                  ),
                  HSeparators.normal(),
                  _selectEditor(
                    context,
                    icon: SvgPicture.asset(Assets.studio),
                    name: 'Android Studio',
                    type: EditorType.androidStudio,
                    onEditorTypeChanged: (EditorType val) {
                      if (_editorTypes.contains(EditorType.none)) {
                        setState(() => _editorTypes = <EditorType>[
                              EditorType.androidStudio
                            ]);
                      } else {
                        if (_editorTypes.contains(EditorType.androidStudio)) {
                          if (_editorTypes.length == 1) {
                            setState(() =>
                                _editorTypes = <EditorType>[EditorType.none]);
                          } else {
                            setState(() =>
                                _editorTypes.remove(EditorType.androidStudio));
                          }
                        } else {
                          setState(
                              () => _editorTypes.add(EditorType.androidStudio));
                        }
                      }
                      widget.onEditorTypeChanged(_editorTypes);
                    },
                    installation: vsCodeNotifier.progress != Progress.none ||
                        androidStudioNotifier.progress != Progress.none,
                    isSelected: _editorTypes.contains(EditorType.androidStudio),
                  ),
                  HSeparators.normal(),
                  _selectEditor(
                    context,
                    icon: Icon(
                      Icons.close_rounded,
                      color: context.read<ThemeChangeNotifier>().isDarkTheme
                          ? Colors.white
                          : Colors.black,
                    ),
                    name: 'None',
                    type: EditorType.none,
                    onEditorTypeChanged: (EditorType val) {
                      setState(
                          () => _editorTypes = <EditorType>[EditorType.none]);
                      widget.onEditorTypeChanged(_editorTypes);
                    },
                    installation: vsCodeNotifier.progress != Progress.none ||
                        androidStudioNotifier.progress != Progress.none,
                    isSelected: _editorTypes.contains(EditorType.none),
                  ),
                ],
              ),
            VSeparators.small(),
            if (widget.isInstalling && !widget.doneInstalling)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: (vsCodeNotifier.progress == Progress.started ||
                        vsCodeNotifier.progress == Progress.checking ||
                        androidStudioNotifier.progress == Progress.checking ||
                        androidStudioNotifier.progress == Progress.started)
                    ? hLoadingIndicator(context: context)
                    : (vsCodeNotifier.progress == Progress.downloading ||
                            androidStudioNotifier.progress ==
                                Progress.downloading)
                        ? CustomProgressIndicator()
                        : (vsCodeNotifier.progress == Progress.extracting ||
                                androidStudioNotifier.progress ==
                                    Progress.extracting)
                            ? hLoadingIndicator(context: context)
                            : (vsCodeNotifier.progress == Progress.done ||
                                    androidStudioNotifier.progress ==
                                        Progress.done)
                                ? welcomeToolInstalled(
                                    context,
                                    title:
                                        '${_editorTypes.length >= 2 ? 'Editors' : 'Editor'} Installed',
                                    message:
                                        '${_editorTypes.length >= 2 ? 'Editors' : 'Editor'} installed successfully on your device. Continue to the next step.',
                                  )
                                : (vsCodeNotifier.progress == Progress.none ||
                                        androidStudioNotifier.progress ==
                                            Progress.none)
                                    ? const SizedBox.shrink()
                                    : CustomProgressIndicator(),
              ),
            if (widget.doneInstalling && !_showEditorSelector)
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: welcomeToolInstalled(
                      context,
                      title:
                          '${_editorTypes.length >= 2 ? 'Editors' : 'Editor'} Installed',
                      message:
                          'You have successfully installed ${_editorTypes.length} ${_editorTypes.length >= 2 ? 'Editors' : 'Editor'}.',
                    ),
                  ),
                  HSeparators.xSmall(),
                  Expanded(
                    flex: 1,
                    child: RectangleButton(
                      height: 75,
                      child: Icon(
                        Icons.edit,
                        color: context.read<ThemeChangeNotifier>().isDarkTheme
                            ? Colors.white
                            : Colors.black,
                      ),
                      onPressed: () {
                        setState(() => _showEditorSelector = true);
                      },
                    ),
                  ),
                ],
              ),
            VSeparators.small(),
            WelcomeButton(
              onInstall: () {
                setState(() => _showEditorSelector = false);
                widget.onInstall();
              },
              onContinue: widget.onContinue,
              progress: _getActivityProgress(),
            ),
          ],
        );
      },
    );
  }
}

Widget _selectEditor(
  BuildContext context, {
  required String name,
  required EditorType type,
  required Widget icon,
  required Function(EditorType)? onEditorTypeChanged,
  required bool isSelected,
  required bool installation,
}) {
  return Expanded(
    child: SizedBox(
      height: 120,
      width: 120,
      child: MaterialButton(
        color: context.read<ThemeChangeNotifier>().isDarkTheme
            ? const Color(0xff1B2529)
            : const Color(0xffF4F8FA),
        onPressed: installation ? null : () => onEditorTypeChanged!(type),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected ? Colors.lightBlueAccent : Colors.transparent,
            width: isSelected ? 3 : 0,
          ),
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isSelected ? 1 : 0.5,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Column(
              children: <Widget>[
                Expanded(child: icon),
                Text(
                  name,
                  style: TextStyle(
                    color: context.read<ThemeChangeNotifier>().isDarkTheme
                        ? Colors.white
                        : const Color(0xff161E21),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
