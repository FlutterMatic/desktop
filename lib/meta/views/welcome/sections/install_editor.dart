import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/ui/round_container.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/meta/utils/app_theme.dart';
import 'package:manager/meta/views/welcome/components/button.dart';
import 'package:manager/meta/views/welcome/components/header_title.dart';
import 'package:manager/meta/views/welcome/components/progress_indicator.dart';
import 'package:provider/provider.dart';

class InstallEditor extends StatefulWidget {
  final EditorType selectedType;
  final VoidCallback onInstall;
  final Function(EditorType) onEditorTypeChanged;
  final bool isInstalling;
  final bool doneInstalling;

  const InstallEditor({
    Key? key,
    required this.selectedType,
    required this.onInstall,
    required this.onEditorTypeChanged,
    required this.isInstalling,
    required this.doneInstalling,
  }) : super(key: key);

  @override
  _InstallEditorState createState() => _InstallEditorState();
}

class _InstallEditorState extends State<InstallEditor> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        welcomeHeaderTitle(
          Assets.editor,
          'Install Editor',
          'You will need to install the Flutter Editor to start using Flutter.',
        ),
        const SizedBox(height: 10),
        if (!widget.isInstalling && !widget.doneInstalling)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: widget.isInstalling ? 0.2 : 1,
              child: IgnorePointer(
                ignoring: widget.isInstalling || widget.doneInstalling,
                child: Row(
                  children: <Widget>[
                    _selectEditor(
                      context,
                      icon: SvgPicture.asset(Assets.studio),
                      name: 'Android Studio',
                      type: EditorType.ANDROID_STUDIO,
                    ),
                    const SizedBox(width: 15),
                    _selectEditor(
                      context,
                      icon: SvgPicture.asset(Assets.vscode),
                      name: 'VS Code',
                      type: EditorType.VSCODE,
                    ),
                    const SizedBox(width: 15),
                    _selectEditor(
                      context,
                      icon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SvgPicture.asset(Assets.studio, height: 30),
                          const SizedBox(width: 10),
                          Container(
                              width: 1, height: 20, color: Colors.white10),
                          const SizedBox(width: 10),
                          SvgPicture.asset(Assets.vscode, height: 30),
                        ],
                      ),
                      name: 'Both',
                      type: EditorType.BOTH,
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 15),
        if (widget.doneInstalling || widget.isInstalling)
          _showSelectedEditor(context, widget.selectedType),
        const SizedBox(height: 15),
        if (widget.isInstalling && !widget.doneInstalling)
          installProgressIndicator(
            disabled: !widget.isInstalling,
            objectSize: '3.2 GB',
          )
        else if (widget.doneInstalling)
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: context.read<ThemeChangeNotifier>().isDarkTheme
                  ? const Color(0xff1B2529)
                  : const Color(0xffF4F8FA),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.check_rounded, color: Color(0xff40CAFF)),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                          'Editor${widget.selectedType == EditorType.BOTH ? 's' : ''} Installed',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                          'You have successfully installed ${widget.selectedType == EditorType.ANDROID_STUDIO ? 'Android Studio' : widget.selectedType == EditorType.VSCODE ? 'Visual Studio Code' : 'Android Studio & Visual Studio Code'}.',
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 30),
        WelcomeButton(
          widget.doneInstalling ? 'Next' : 'Install',
          widget.onInstall,
          disabled: widget.isInstalling,
        ),
      ],
    );
  }

  Widget _selectEditor(
    BuildContext context, {
    required String name,
    required EditorType type,
    required Widget icon,
  }) {
    bool _selected = widget.selectedType == type;
    return Expanded(
      child: SizedBox(
        height: 120,
        width: 120,
        child: MaterialButton(
          color: context.read<ThemeChangeNotifier>().isDarkTheme
              ? const Color(0xff1B2529)
              : const Color(0xffF4F8FA),
          onPressed: () => widget.onEditorTypeChanged(type),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: _selected ? Colors.lightBlueAccent : Colors.transparent,
              width: _selected ? 3 : 0,
            ),
          ),
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
    );
  }
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
