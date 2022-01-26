// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/app/constants/enum.dart';
import 'package:fluttermatic/components/widgets/ui/warning_widget.dart';
import 'package:fluttermatic/core/services/checks/studio.check.dart';
import 'package:fluttermatic/core/services/checks/vsc.check.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';
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
    return Consumer2<VSCodeNotifier, AndroidStudioNotifier>(
      builder: (BuildContext context, VSCodeNotifier vsCodeNotifier,
          AndroidStudioNotifier androidStudioNotifier, _) {
        Progress _getProgress() {
          if (_editorTypes.contains(EditorType.none)) {
            return Progress.done;
          } else if (_editorTypes.contains(EditorType.vscode)) {
            if (_editorTypes.contains(EditorType.androidStudio)) {
              if (vsCodeNotifier.progress != Progress.done) {
                return vsCodeNotifier.progress;
              } else if (androidStudioNotifier.progress != Progress.done) {
                return androidStudioNotifier.progress;
              } else {
                return Progress.done;
              }
            } else {
              return vsCodeNotifier.progress;
            }
          } else if (_editorTypes.contains(EditorType.androidStudio)) {
            if (_editorTypes.contains(EditorType.vscode)) {
              if (androidStudioNotifier.progress != Progress.done) {
                return androidStudioNotifier.progress;
              } else if (vsCodeNotifier.progress != Progress.done) {
                return vsCodeNotifier.progress;
              } else {
                return Progress.done;
              }
            } else {
              return androidStudioNotifier.progress;
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
                  if (vsCodeNotifier.progress == Progress.started ||
                      vsCodeNotifier.progress == Progress.checking ||
                      androidStudioNotifier.progress == Progress.checking ||
                      androidStudioNotifier.progress == Progress.started) {
                    return hLoadingIndicator(context: context);
                  } else if (vsCodeNotifier.progress == Progress.extracting ||
                      androidStudioNotifier.progress == Progress.extracting) {
                    return hLoadingIndicator(context: context);
                  } else if (vsCodeNotifier.progress == Progress.done &&
                      androidStudioNotifier.progress == Progress.done) {
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
                      } else if (!_editorTypes
                          .contains(EditorType.androidStudio)) {
                        setState(
                            () => _editorTypes.add(EditorType.androidStudio));
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
                      color: Theme.of(context).isDarkTheme
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
            VSeparators.normal(),
            SetUpButton(
              buttonText: _getProgress() == Progress.done ? 'Continue' : null,
              onInstall: widget.onInstall,
              onContinue: widget.onContinue,
              progress: _getProgress(),
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
        color: Theme.of(context).isDarkTheme
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
                    color: Theme.of(context).isDarkTheme
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
