import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
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
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            _selectEditor(
              context,
              icon: SvgPicture.asset(Assets.vscode),
              name: 'VS Code',
              type: EditorType.VSCODE,
              onEditorTypeChanged: onEditorTypeChanged,
              selectedType: selectedType,
              installtion: vsCodeNotifier.progress != Progress.NONE ||
                  androidStudioNotifier.progress != Progress.NONE,
            ),
            const SizedBox(width: 15),
            _selectEditor(
              context,
              icon: SvgPicture.asset(Assets.studio),
              name: 'Android Studio',
              type: EditorType.ANDROID_STUDIO,
              onEditorTypeChanged: onEditorTypeChanged,
              selectedType: selectedType,
              installtion: vsCodeNotifier.progress != Progress.NONE ||
                  androidStudioNotifier.progress != Progress.NONE,
            ),
            const SizedBox(width: 15),
            _selectEditor(
              context,
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SvgPicture.asset(Assets.studio, height: 30),
                  const SizedBox(width: 10),
                  Container(width: 1, height: 20, color: Colors.white10),
                  const SizedBox(width: 10),
                  SvgPicture.asset(Assets.vscode, height: 30),
                ],
              ),
              name: 'Both',
              type: EditorType.BOTH,
              onEditorTypeChanged: onEditorTypeChanged,
              selectedType: selectedType,
              installtion: vsCodeNotifier.progress != Progress.NONE ||
                  androidStudioNotifier.progress != Progress.NONE,
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (isInstalling && !doneInstalling)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: (vsCodeNotifier.progress == Progress.STARTED ||
                    vsCodeNotifier.progress == Progress.CHECKING ||
                    androidStudioNotifier.progress == Progress.CHECKING ||
                    androidStudioNotifier.progress == Progress.STARTED)
                ? Column(
                    children: <Widget>[
                      hLoadingIndicator(
                        context: context,
                        message:
                            'Checking for ${selectedType.index == 0 ? 'Visual Studio Code' : selectedType.index == 1 ? 'Android Studio' : 'Both'}',
                      ),
                      Text(
                          'Checking for ${selectedType.index == 0 ? 'Visual Studio Code' : selectedType.index == 1 ? 'Android Studio' : 'Both'}'),
                    ],
                  )
                : (vsCodeNotifier.progress == Progress.DOWNLOADING ||
                        androidStudioNotifier.progress == Progress.DOWNLOADING)
                    ? CustomProgressIndicator(
                        disabled: ((vsCodeNotifier.progress !=
                                    Progress.CHECKING ||
                                androidStudioNotifier.progress !=
                                    Progress.CHECKING) &&
                            (vsCodeNotifier.progress != Progress.DOWNLOADING ||
                                androidStudioNotifier.progress !=
                                    Progress.DOWNLOADING) &&
                            (vsCodeNotifier.progress != Progress.STARTED ||
                                androidStudioNotifier.progress !=
                                    Progress.STARTED)),
                        progress:
                            vsCodeNotifier.progress != Progress.DOWNLOADING
                                ? androidStudioNotifier.progress
                                : vsCodeNotifier.progress,
                        toolName: selectedType.index == 0
                            ? 'Visual Studio Code'
                            : selectedType.index == 1
                                ? 'Android Studio'
                                : 'Both',
                        onCancel: onCancel,
                        message:
                            'Downloading  ${vsCodeNotifier.progress == Progress.DOWNLOADING ? 'Visual Studio Code' : androidStudioNotifier.progress == Progress.DOWNLOADING ? 'Android Studio' : 'Editors'}',
                      )
                    : (vsCodeNotifier.progress == Progress.EXTRACTING ||
                            androidStudioNotifier.progress ==
                                Progress.EXTRACTING)
                        ? Tooltip(
                            message:
                                vsCodeNotifier.progress == Progress.DOWNLOADING
                                    ? 'Extracting Visual Studio Code'
                                    : androidStudioNotifier.progress ==
                                            Progress.DOWNLOADING
                                        ? 'Extracting Android Studio'
                                        : 'Extracting files',
                            child: Lottie.asset(
                              Assets.extracting,
                              height: 100,
                            ),
                          )
                        : (vsCodeNotifier.progress == Progress.DONE ||
                                androidStudioNotifier.progress == Progress.DONE)
                            ? welcomeToolInstalled(
                                context,
                                title:
                                    '${selectedType.index == 0 ? 'Visual Studio Code Editor' : selectedType.index == 1 ? 'Android Studio IDE' : 'Both Editors'} Installed',
                                message:
                                    '${selectedType.index == 0 ? 'Visual Studio Code Editor was' : selectedType.index == 1 ? 'Android Studio IDE was' : 'Both Editors were'} installed successfully on your machine. Continue to the next step.',
                              )
                            : (vsCodeNotifier.progress == Progress.NONE ||
                                    androidStudioNotifier.progress ==
                                        Progress.NONE)
                                ? const SizedBox.shrink()
                                : CustomProgressIndicator(
                                    disabled: ((vsCodeNotifier.progress !=
                                                Progress.CHECKING ||
                                            androidStudioNotifier.progress !=
                                                Progress.CHECKING) &&
                                        (vsCodeNotifier.progress !=
                                                Progress.DOWNLOADING ||
                                            androidStudioNotifier.progress !=
                                                Progress.DOWNLOADING) &&
                                        (vsCodeNotifier.progress !=
                                                Progress.STARTED ||
                                            androidStudioNotifier.progress !=
                                                Progress.STARTED)),
                                    progress:
                                        vsCodeNotifier.progress == Progress.NONE
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
        const SizedBox(height: 15),
        // if (doneInstalling || isInstalling)
        //   _showSelectedEditor(context, selectedType),
        // const SizedBox(height: 15),
        // if (isInstalling && !doneInstalling)
        //   CustomProgressIndicator(
        //     disabled: !isInstalling,
        //     progress: androidStudioNotifier.progress == Progress.NONE
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
                'Editor${selectedType == EditorType.BOTH ? 's' : ''} Installed',
            message:
                'You have successfully installed ${selectedType == EditorType.ANDROID_STUDIO ? 'Android Studio' : selectedType == EditorType.VSCODE ? 'Visual Studio Code' : 'Android Studio & Visual Studio Code'}.',
          ),
        const SizedBox(height: 30),
        WelcomeButton(
          onContinue: onContinue,
          onInstall: onInstall,
          progress: selectedType == EditorType.BOTH
              ? (vsCodeNotifier.progress != Progress.NONE &&
                      vsCodeNotifier.progress != Progress.DONE
                  ? vsCodeNotifier.progress
                  : androidStudioNotifier.progress)
              : selectedType == EditorType.VSCODE
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
    required bool installtion}) {
  bool _selected = selectedType == type;
  return Expanded(
    child: SizedBox(
      height: 120,
      width: 120,
      child: MaterialButton(
        color: context.read<ThemeChangeNotifier>().isDarkTheme
            ? const Color(0xff1B2529)
            : const Color(0xffF4F8FA),
        onPressed: installtion ? null : () => onEditorTypeChanged!(type),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: _selected ? Colors.lightBlueAccent : Colors.transparent,
            width: _selected ? 3 : 0,
          ),
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _selected ? 1 : 0.2,
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
              const SizedBox(height: 5),
              Text(
                editorType == EditorType.BOTH
                    ? 'Android Studio & Visual Studio Code'
                    : editorType == EditorType.ANDROID_STUDIO
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
        if (editorType == EditorType.ANDROID_STUDIO)
          SvgPicture.asset(Assets.studio),
        if (editorType == EditorType.VSCODE) SvgPicture.asset(Assets.vscode),
        if (editorType == EditorType.BOTH)
          Row(
            children: <Widget>[
              SvgPicture.asset(Assets.studio, height: 25),
              const SizedBox(width: 10),
              Container(width: 1, height: 20, color: Colors.white10),
              const SizedBox(width: 10),
              SvgPicture.asset(Assets.vscode, height: 25),
            ],
          ),
      ],
    ),
  );
}
