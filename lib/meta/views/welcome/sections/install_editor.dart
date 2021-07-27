
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/meta/views/welcome/components/button.dart';
import 'package:manager/meta/views/welcome/components/header_title.dart';
import 'package:manager/meta/views/welcome/components/progress_indicator.dart';

Widget installEditor(
  Function onInstall, {
  required EditorType selectedType,
  required Function(EditorType) onEditorTypeChanged,
  required bool isInstalling,
  required bool doneInstalling,
  required double completedSize,
  required double totalInstalled,
}) {
  Widget _selectEditor(
      {required String name, required EditorType type, required Widget icon}) {
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
      welcomeHeaderTitle(
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
                type: EditorType.Android_Studio,
              ),
              const SizedBox(width: 15),
              _selectEditor(
                icon: SvgPicture.asset('assets/images/logos/vs_code.svg'),
                name: 'VS Code',
                type: EditorType.VS_Code,
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
                type: EditorType.Both,
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
                        'Editor${selectedType ==EditorType.Both ? 's' : ''} Installed',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                        'You have successfully installed ${selectedType == EditorType.Android_Studio ? 'Android Studio' : selectedType == EditorType.VS_Code ? 'Visual Studio Code' : 'Android Studio & Visual Studio Code'}.',
                        style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: 30),
      welcomeButton(doneInstalling ? 'Next' : 'Install', onInstall,
          disabled: isInstalling),
    ],
  );
}