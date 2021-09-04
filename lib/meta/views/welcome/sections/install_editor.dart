import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/ui/round_container.dart';
import 'package:manager/core/libraries/checks.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/meta/utils/app_theme.dart';
import 'package:manager/core/libraries/components.dart';
import 'package:provider/provider.dart';

Widget installEditor(
  BuildContext context, {
  required EditorType selectedType,
  required VoidCallback onInstall,
  required VoidCallback onContinue,
  required VoidCallback onCancel,
  required Function(EditorType) onEditorTypeChanged,
  required bool isInstalling,
  required bool doneInstalling,
}) {
  return Consumer2<VSCodeNotifier, AndroidStudioNotifier>(builder:
      (BuildContext context, VSCodeNotifier vsCodeNotifier,
          AndroidStudioNotifier androidStudioNotifier, _) {
    return Column(
      children: <Widget>[
        welcomeHeaderTitle(
          Assets.editor,
          'Install Editor',
          'You will need to install the Flutter Editor to start using Flutter.',
        ),
        VSeparators.small(),
        Row(
          children: <Widget>[
            _selectEditor(
              context,
              icon: SvgPicture.asset(Assets.vscode),
              name: 'VS Code',
              type: EditorType.vscode,
              onEditorTypeChanged: onEditorTypeChanged,
              selectedType: selectedType,
              installation: vsCodeNotifier.progress != Progress.none ||
                  androidStudioNotifier.progress != Progress.none,
            ),
            HSeparators.normal(),
            _selectEditor(
              context,
              icon: SvgPicture.asset(Assets.studio),
              name: 'Android Studio',
              type: EditorType.androidStudio,
              onEditorTypeChanged: onEditorTypeChanged,
              selectedType: selectedType,
              installation: vsCodeNotifier.progress != Progress.none ||
                  androidStudioNotifier.progress != Progress.none,
            ),
            HSeparators.normal(),
            _selectEditor(
              context,
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SvgPicture.asset(Assets.studio, height: 30),
                  HSeparators.small(),
                  Container(width: 1, height: 20, color: Colors.white10),
                  HSeparators.small(),
                  SvgPicture.asset(Assets.vscode, height: 30),
                ],
              ),
              name: 'Both',
              type: EditorType.both,
              onEditorTypeChanged: onEditorTypeChanged,
              selectedType: selectedType,
              installation: vsCodeNotifier.progress != Progress.none ||
                  androidStudioNotifier.progress != Progress.none,
            ),
          ],
        ),
        VSeparators.small(),
        if (isInstalling && !doneInstalling)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: (vsCodeNotifier.progress == Progress.started ||
                    vsCodeNotifier.progress == Progress.checking ||
                    androidStudioNotifier.progress == Progress.checking ||
                    androidStudioNotifier.progress == Progress.started)
                ? Column(
                    children: <Widget>[
                      hLoadingIndicator(
                        context: context,
                      ),
                      Text(
                          'Checking for ${selectedType.index == 0 ? 'Visual Studio Code' : selectedType.index == 1 ? 'Android Studio' : 'Both'}'),
                    ],
                  )
                : (vsCodeNotifier.progress == Progress.downloading ||
                        androidStudioNotifier.progress == Progress.downloading)
                    ? CustomProgressIndicator(
                        disabled: ((vsCodeNotifier.progress !=
                                    Progress.checking ||
                                androidStudioNotifier.progress !=
                                    Progress.checking) &&
                            (vsCodeNotifier.progress != Progress.downloading ||
                                androidStudioNotifier.progress !=
                                    Progress.downloading) &&
                            (vsCodeNotifier.progress != Progress.started ||
                                androidStudioNotifier.progress !=
                                    Progress.started)),
                        progress:
                            vsCodeNotifier.progress != Progress.downloading
                                ? androidStudioNotifier.progress
                                : vsCodeNotifier.progress,
                        toolName: selectedType.index == 0
                            ? 'Visual Studio Code'
                            : selectedType.index == 1
                                ? 'Android Studio'
                                : 'Both',
                        onCancel: onCancel,
                        message:
                            'Downloading  ${vsCodeNotifier.progress == Progress.downloading ? 'Visual Studio Code' : androidStudioNotifier.progress == Progress.downloading ? 'Android Studio' : 'Editors'}',
                      )
                    : (vsCodeNotifier.progress == Progress.extracting ||
                            androidStudioNotifier.progress ==
                                Progress.extracting)
                        ? Column(
                            children: <Widget>[
                              hLoadingIndicator(
                                context: context,
                              ),
                              Text(
                                'Extracting ${vsCodeNotifier.progress == Progress.downloading ? 'Visual Studio Code' : androidStudioNotifier.progress == Progress.downloading ? 'Android Studio' : 'Editors'}',
                              ),
                            ],
                          )
                        : (vsCodeNotifier.progress == Progress.done ||
                                androidStudioNotifier.progress == Progress.done)
                            ? welcomeToolInstalled(
                                context,
                                title:
                                    '${selectedType.index == 0 ? 'Visual Studio Code Editor' : selectedType.index == 1 ? 'Android Studio IDE' : 'Both Editors'} Installed',
                                message:
                                    '${selectedType.index == 0 ? 'Visual Studio Code Editor was' : selectedType.index == 1 ? 'Android Studio IDE was' : 'Both Editors were'} installed successfully on your machine. Continue to the next step.',
                              )
                            : (vsCodeNotifier.progress == Progress.none ||
                                    androidStudioNotifier.progress ==
                                        Progress.none)
                                ? const SizedBox.shrink()
                                : CustomProgressIndicator(
                                    disabled: ((vsCodeNotifier.progress !=
                                                Progress.checking ||
                                            androidStudioNotifier.progress !=
                                                Progress.checking) &&
                                        (vsCodeNotifier.progress !=
                                                Progress.downloading ||
                                            androidStudioNotifier.progress !=
                                                Progress.downloading) &&
                                        (vsCodeNotifier.progress !=
                                                Progress.started ||
                                            androidStudioNotifier.progress !=
                                                Progress.started)),
                                    progress:
                                        vsCodeNotifier.progress == Progress.none
                                            ? androidStudioNotifier.progress
                                            : vsCodeNotifier.progress,
                                    toolName: selectedType.index == 0
                                        ? 'Visual Studio Code Editor'
                                        : selectedType.index == 1
                                            ? 'Android Studio IDE'
                                            : 'Both Editors',
                                    onCancel: onCancel,
                                    message:
                                        'Downloading ${selectedType.index == 0 ? 'Visual Studio Code' : selectedType.index == 1 ? 'Android Studio' : 'Editors'}',
                                  ),
          ),
        VSeparators.normal(),
        // if (doneInstalling || isInstalling)
        //   _showSelectedEditor(context, selectedType),
        // VSeparators.normal(),
        // if (isInstalling && !doneInstalling)
        //   CustomProgressIndicator(
        //     disabled: !isInstalling,
        //     progress: androidStudioNotifier.progress == Progress.none
        //         ? vsCodeNotifier.progress
        //         : androidStudioNotifier.progress,
        //     onCancel: () {},
        //     toolName: 'Editor(s)',
        //   )
        // else
        if (doneInstalling)
          welcomeToolInstalled(
            context,
            title:
                'Editor${selectedType == EditorType.both ? 's' : ''} Installed',
            message:
                'You have successfully installed ${selectedType == EditorType.androidStudio ? 'Android Studio' : selectedType == EditorType.vscode ? 'Visual Studio Code' : 'Android Studio & Visual Studio Code'}.',
          ),
        VSeparators.xLarge(),
        WelcomeButton(
          onContinue: onContinue,
          onInstall: onInstall,
          progress: selectedType == EditorType.both
              ? (vsCodeNotifier.progress != Progress.none &&
                      vsCodeNotifier.progress != Progress.done
                  ? vsCodeNotifier.progress
                  : androidStudioNotifier.progress)
              : selectedType == EditorType.vscode
                  ? vsCodeNotifier.progress
                  : androidStudioNotifier.progress,
          toolName: 'Editor',
        ),
      ],
    );
  });
}

Widget _selectEditor(BuildContext context,
    {required String name,
    required EditorType type,
    required Widget icon,
    required Function(EditorType)? onEditorTypeChanged,
    required EditorType? selectedType,
    required bool installation}) {
  bool _selected = selectedType == type;
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
            color: _selected ? Colors.lightBlueAccent : Colors.transparent,
            width: _selected ? 3 : 0,
          ),
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _selected ? 1 : 0.5,
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

Widget _showSelectedEditor(BuildContext context, EditorType editorType) {
  return RoundContainer(
    child: Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Selected Option', style: TextStyle(fontSize: 14)),
              VSeparators.xSmall(),
              Text(
                editorType == EditorType.both
                    ? 'Android Studio & Visual Studio Code'
                    : editorType == EditorType.androidStudio
                        ? 'Android Studio'
                        : 'Visual Studio',
                style: TextStyle(
                  fontSize: 15,
                  color: context.read<ThemeChangeNotifier>().isDarkTheme
                      ? AppTheme.darkLightColor
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
        if (editorType == EditorType.androidStudio)
          SvgPicture.asset(Assets.studio),
        if (editorType == EditorType.vscode) SvgPicture.asset(Assets.vscode),
        if (editorType == EditorType.both)
          Row(
            children: <Widget>[
              SvgPicture.asset(Assets.studio, height: 25),
              HSeparators.small(),
              Container(width: 1, height: 20, color: Colors.white10),
              HSeparators.small(),
              SvgPicture.asset(Assets.vscode, height: 25),
            ],
          ),
      ],
    ),
  );
}
