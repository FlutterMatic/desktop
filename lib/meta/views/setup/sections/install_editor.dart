// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/enum.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/core/notifiers/models/state/checks/studio.dart';
import 'package:fluttermatic/core/notifiers/models/state/checks/vsc.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/theme.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/meta/views/setup/components/button.dart';
import 'package:fluttermatic/meta/views/setup/components/header_title.dart';
import 'package:fluttermatic/meta/views/setup/components/loading_indicator.dart';
import 'package:fluttermatic/meta/views/setup/components/progress_indicator.dart';
import 'package:fluttermatic/meta/views/setup/components/tool_installed.dart';

class SetUpInstallEditor extends StatefulWidget {
  final VoidCallback onInstall;
  final VoidCallback onContinue;
  final Function(List<EditorType>) onEditorTypeChanged;
  final bool isInstalling;
  final bool doneInstalling;

  const SetUpInstallEditor({
    Key? key,
    required this.onInstall,
    required this.onContinue,
    required this.onEditorTypeChanged,
    required this.isInstalling,
    required this.doneInstalling,
  }) : super(key: key);

  @override
  _SetUpInstallEditorState createState() => _SetUpInstallEditorState();
}

class _SetUpInstallEditorState extends State<SetUpInstallEditor> {
  List<EditorType> _editorTypes = <EditorType>[
    EditorType.androidStudio,
    EditorType.vscode,
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        ThemeState themeState = ref.watch(themeStateController);

        VSCState vscState = ref.watch(vscNotifierController);

        AndroidStudioState androidStudioState =
            ref.watch(androidStudioNotifierController);

        Progress getProgress() {
          if (_editorTypes.contains(EditorType.none)) {
            return Progress.done;
          } else if (_editorTypes.contains(EditorType.vscode)) {
            if (_editorTypes.contains(EditorType.androidStudio)) {
              if (vscState.progress != Progress.done) {
                return vscState.progress;
              } else if (androidStudioState.progress != Progress.done) {
                return androidStudioState.progress;
              } else {
                return Progress.done;
              }
            } else {
              return vscState.progress;
            }
          } else if (_editorTypes.contains(EditorType.androidStudio)) {
            if (_editorTypes.contains(EditorType.vscode)) {
              if (androidStudioState.progress != Progress.done) {
                return androidStudioState.progress;
              } else if (vscState.progress != Progress.done) {
                return vscState.progress;
              } else {
                return Progress.done;
              }
            } else {
              return androidStudioState.progress;
            }
          } else {
            return Progress.done;
          }
        }

        return Column(
          children: <Widget>[
            setUpHeaderTitle(
              Assets.editor,
              'Install Editor',
              'You will need to install an editor that supports Flutter to start developing your apps.',
            ),
            VSeparators.normal(),
            if (_editorTypes.contains(EditorType.none))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: informationWidget(
                  'We recommend selecting an editor. If an editor is already installed, select it and we will check if you have all necessary tools for it available.',
                  type: InformationType.warning,
                ),
              ),
            if (widget.isInstalling || widget.doneInstalling)
              Builder(
                builder: (_) {
                  if (vscState.progress == Progress.started ||
                      vscState.progress == Progress.checking ||
                      androidStudioState.progress == Progress.checking ||
                      androidStudioState.progress == Progress.started) {
                    return hLoadingIndicator(context: context);
                  } else if (vscState.progress == Progress.extracting ||
                      androidStudioState.progress == Progress.extracting) {
                    return hLoadingIndicator(context: context);
                  } else if (vscState.progress == Progress.done &&
                      androidStudioState.progress == Progress.done) {
                    return setUpToolInstalled(
                      context,
                      title:
                          '${_editorTypes.length > 1 ? 'Editors' : 'Editor'} Installed',
                      message:
                          '${_editorTypes.length > 1 ? 'Editors' : 'Editor'} installed successfully on your device. You can now continue to the next step.',
                    );
                  } else {
                    return const CustomProgressIndicator();
                  }
                },
              )
            else
              Row(
                children: <Widget>[
                  _selectEditor(
                    context,
                    icon: SvgPicture.asset(Assets.vscode),
                    isDarkTheme: themeState.darkTheme,
                    name: 'VS Code',
                    type: EditorType.vscode,
                    onEditorTypeChanged: (EditorType val) {
                      if (_editorTypes.contains(EditorType.none)) {
                        setState(() =>
                            _editorTypes = <EditorType>[EditorType.vscode]);
                      } else if (!_editorTypes.contains(EditorType.vscode)) {
                        setState(() => _editorTypes.add(EditorType.vscode));
                      }
                      widget.onEditorTypeChanged(_editorTypes);
                    },
                    installation: vscState.progress != Progress.none ||
                        androidStudioState.progress != Progress.none,
                    isSelected: _editorTypes.contains(EditorType.vscode),
                  ),
                  HSeparators.normal(),
                  _selectEditor(
                    context,
                    icon: SvgPicture.asset(Assets.studio),
                    isDarkTheme: themeState.darkTheme,
                    name: 'Android Studio',
                    type: EditorType.androidStudio,
                    onEditorTypeChanged: (EditorType val) {
                      if (_editorTypes.contains(EditorType.none)) {
                        setState(() => _editorTypes = <EditorType>[
                              EditorType.androidStudio
                            ]);
                      } else if (!_editorTypes
                          .contains(EditorType.androidStudio)) {
                        setState(
                            () => _editorTypes.add(EditorType.androidStudio));
                      }

                      widget.onEditorTypeChanged(_editorTypes);
                    },
                    installation: vscState.progress != Progress.none ||
                        androidStudioState.progress != Progress.none,
                    isSelected: _editorTypes.contains(EditorType.androidStudio),
                  ),
                  HSeparators.normal(),
                  _selectEditor(
                    context,
                    icon: Icon(
                      Icons.close_rounded,
                      color: themeState.darkTheme ? Colors.white : Colors.black,
                    ),
                    isDarkTheme: themeState.darkTheme,
                    name: 'None',
                    type: EditorType.none,
                    onEditorTypeChanged: (EditorType val) {
                      setState(
                          () => _editorTypes = <EditorType>[EditorType.none]);
                      widget.onEditorTypeChanged(_editorTypes);
                    },
                    installation: vscState.progress != Progress.none ||
                        androidStudioState.progress != Progress.none,
                    isSelected: _editorTypes.contains(EditorType.none),
                  ),
                ],
              ),
            VSeparators.normal(),
            SetUpButton(
              buttonText: getProgress() == Progress.done ? 'Continue' : null,
              onInstall: widget.onInstall,
              onContinue: widget.onContinue,
              progress: getProgress(),
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
  required bool isDarkTheme,
}) {
  return Expanded(
    child: SizedBox(
      height: 120,
      width: 120,
      child: MaterialButton(
        color: isDarkTheme ? const Color(0xff1B2529) : const Color(0xffF4F8FA),
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
                    color: isDarkTheme ? Colors.white : const Color(0xff161E21),
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
