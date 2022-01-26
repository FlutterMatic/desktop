// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/inputs/check_box_element.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/warning_widget.dart';

class ProjectPlatformsSection extends StatefulWidget {
  final bool ios;
  final bool android;
  final bool web;
  final bool windows;
  final bool macos;
  final bool linux;

  final Function({
    bool ios,
    bool android,
    bool web,
    bool windows,
    bool macos,
    bool linux,
  }) onChanged;

  const ProjectPlatformsSection({
    Key? key,
    required this.onChanged,
    required this.ios,
    required this.android,
    required this.web,
    required this.windows,
    required this.macos,
    required this.linux,
  }) : super(key: key);

  @override
  _ProjectPlatformsSectionState createState() =>
      _ProjectPlatformsSectionState();
}

class _ProjectPlatformsSectionState extends State<ProjectPlatformsSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
            'Choose which environments you want to enable for your new Flutter project.'),
        VSeparators.normal(),
        RoundContainer(
          color: Colors.blueGrey.withOpacity(0.1),
          child: Row(
            children: <Widget>[
              Expanded(
                child: CheckBoxElement(
                  onChanged: (bool? val) {
                    widget.onChanged(
                      ios: val ?? true,
                      android: widget.android,
                      web: widget.web,
                      windows: widget.windows,
                      macos: widget.macos,
                      linux: widget.linux,
                    );
                  },
                  value: widget.ios,
                  text: 'iOS',
                ),
              ),
              HSeparators.normal(),
              Expanded(
                child: CheckBoxElement(
                  onChanged: (bool? val) {
                    widget.onChanged(
                      ios: widget.ios,
                      android: val ?? true,
                      web: widget.web,
                      windows: widget.windows,
                      macos: widget.macos,
                      linux: widget.linux,
                    );
                  },
                  value: widget.android,
                  text: 'Android',
                ),
              ),
              HSeparators.normal(),
              Expanded(
                child: CheckBoxElement(
                  onChanged: (bool? val) {
                    widget.onChanged(
                      ios: widget.ios,
                      android: widget.android,
                      web: val ?? true,
                      windows: widget.windows,
                      macos: widget.macos,
                      linux: widget.linux,
                    );
                  },
                  value: widget.web,
                  text: 'Web',
                ),
              ),
            ],
          ),
        ),
        VSeparators.normal(),
        RoundContainer(
          color: Colors.blueGrey.withOpacity(0.1),
          child: Row(
            children: <Widget>[
              Expanded(
                child: CheckBoxElement(
                  onChanged: (bool? val) {
                    widget.onChanged(
                      ios: widget.ios,
                      android: widget.android,
                      web: widget.web,
                      windows: val ?? true,
                      macos: widget.macos,
                      linux: widget.linux,
                    );
                  },
                  value: widget.windows,
                  text: 'Windows',
                ),
              ),
              HSeparators.normal(),
              Expanded(
                child: CheckBoxElement(
                  onChanged: (bool? val) {
                    widget.onChanged(
                      ios: widget.ios,
                      android: widget.android,
                      web: widget.web,
                      windows: widget.windows,
                      macos: val ?? true,
                      linux: widget.linux,
                    );
                  },
                  value: widget.macos,
                  text: 'MacOS',
                ),
              ),
              HSeparators.normal(),
              Expanded(
                child: CheckBoxElement(
                  onChanged: (bool? val) {
                    widget.onChanged(
                      ios: widget.ios,
                      android: widget.android,
                      web: widget.web,
                      windows: widget.windows,
                      macos: widget.macos,
                      linux: val ?? true,
                    );
                  },
                  value: widget.linux,
                  text: 'Linux',
                ),
              ),
            ],
          ),
        ),
        VSeparators.normal(),
        informationWidget(
          'Dart supports null-safety. Null safety helps you catch probable bugs before they happen. Learn more about null-safety from the official Dart documentations. Null-safety is enabled by default.',
          type: InformationType.info,
        ),
        VSeparators.normal(),
        if (!validatePlatformSelection(
          ios: widget.ios,
          android: widget.android,
          web: widget.web,
          windows: widget.windows,
          macos: widget.macos,
          linux: widget.linux,
        ))
          informationWidget(
            'You will need to choose at least one platform. You will be able to change it later.',
            type: InformationType.error,
          ),
      ],
    );
  }
}

bool validatePlatformSelection({
  required bool ios,
  required bool android,
  required bool web,
  required bool windows,
  required bool macos,
  required bool linux,
}) {
  return !(ios == false &&
      android == false &&
      web == false &&
      windows == false &&
      macos == false &&
      linux == false);
}
