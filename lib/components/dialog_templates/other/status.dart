// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/enum.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/dialog_templates/other/install_tool.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/installation_status.dart';
import 'package:fluttermatic/components/widgets/ui/shimmer.dart';
import 'package:fluttermatic/components/widgets/ui/stage_tile.dart';

class StatusDialog extends StatefulWidget {
  const StatusDialog({Key? key}) : super(key: key);

  @override
  State<StatusDialog> createState() => _StatusDialogState();
}

class _StatusDialogState extends State<StatusDialog> {
  bool _loading = true;

  bool _flutterInstalled = false;
  bool _dartInstalled = false;
  bool _javaInstalled = false;
  bool _gitInstalled = false;
  bool _vscodeInstalled = false;
  bool _studioInstalled = false;

  Future<void> _loadStatus() async {
    // TODO: Load status from state

    // ServiceCheckResponse _flutter = await CheckServices.checkFlutter();
    // ServiceCheckResponse _dart = await CheckServices.checkDart();
    // ServiceCheckResponse _git = await CheckServices.checkGit();
    // ServiceCheckResponse _java = await CheckServices.checkJava();
    // ServiceCheckResponse _vscode = await CheckServices.checkVSCode();
    // ServiceCheckResponse _adb = await CheckServices.checkADBridge();

    // if (mounted) {
    //   setState(() {
    //     _flutterInstalled = _flutter.version != null;
    //     _dartInstalled = _dart.version != null;
    //     _javaInstalled = _java.version != null;
    //     _vscodeInstalled = _vscode.version != null;
    //     _studioInstalled = _adb.version != null;
    //     _gitInstalled = _git.version != null;
    //     _loading = false;
    //   });
    // }
  }

  @override
  void initState() {
    _loadStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: _loading
          ? Shimmer.fromColors(
              child: Column(
                children: <Widget>[
                  const DialogHeader(title: 'Status'),
                  ...<String>[
                    'Dart',
                    'Flutter',
                    'Android Studio',
                    'VS Code',
                    'Git',
                    'Java'
                  ].map(
                    (_) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: InstallationStatusTile(
                          status: InstallationStatus.done,
                          title: _,
                          description: '...',
                          tooltip: '...',
                          onDownload: () {},
                        ),
                      );
                    },
                  ).toList(),
                  RectangleButton(
                    width: double.infinity,
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            )
          : Column(
              children: <Widget>[
                const DialogHeader(
                  title: 'Status',
                  leading: StageTile(),
                ),
                // Dart
                InstallationStatusTile(
                  status: _dartInstalled
                      ? InstallationStatus.done
                      : InstallationStatus.error,
                  title:
                      _dartInstalled ? 'Dart Installed' : 'Dart Not Installed',
                  description:
                      'You will need to have Dart installed on your device. This is the language that Flutter uses to build the app.',
                  onDownload: () => showDialog(
                    context: context,
                    builder: (_) =>
                        const InstallToolDialog(tool: SetUpTab.installFlutter),
                  ),
                  tooltip: 'Dart',
                ),
                VSeparators.normal(),
                // Flutter
                InstallationStatusTile(
                  status: _flutterInstalled
                      ? InstallationStatus.done
                      : InstallationStatus.error,
                  title: _flutterInstalled
                      ? 'Flutter Installed'
                      : 'Flutter Not Installed',
                  description:
                      'You will need to have Flutter installed on your device. This is how your device will be able to understand the Dart language.',
                  onDownload: () => showDialog(
                    context: context,
                    builder: (_) =>
                        const InstallToolDialog(tool: SetUpTab.installFlutter),
                  ),
                  tooltip: 'Flutter',
                ),
                VSeparators.normal(),
                // Android Studio
                InstallationStatusTile(
                  status: _studioInstalled
                      ? InstallationStatus.done
                      : InstallationStatus.warning,
                  title: _studioInstalled
                      ? 'Android Studio Installed'
                      : 'Android Studio Not Installed',
                  description:
                      'You will need to have Android Studio installed on your device if you want to develop Android apps with Flutter.',
                  onDownload: () => showDialog(
                    context: context,
                    builder: (_) =>
                        const InstallToolDialog(tool: SetUpTab.installEditor),
                  ),
                  tooltip: 'Studio',
                ),
                VSeparators.normal(),
                // VS Code
                InstallationStatusTile(
                  status: _vscodeInstalled
                      ? InstallationStatus.done
                      : InstallationStatus.warning,
                  title: _vscodeInstalled
                      ? 'VS Code Installed'
                      : 'VS Code Not Installed',
                  description:
                      'VS Code is an optional editor that is used by many Flutter developers to develop Flutter apps. It is not required to develop Flutter apps, but preferred.',
                  onDownload: () => showDialog(
                    context: context,
                    builder: (_) =>
                        const InstallToolDialog(tool: SetUpTab.installEditor),
                  ),
                  tooltip: 'VS Code',
                ),
                VSeparators.normal(),
                // Git
                InstallationStatusTile(
                  status: _gitInstalled
                      ? InstallationStatus.done
                      : InstallationStatus.error,
                  title: _gitInstalled ? 'Git Installed' : 'Git Not Installed',
                  description:
                      'You will need to have Git installed on your device. This is used to manage pub packages and also keep Flutter up-to-date.',
                  onDownload: () => showDialog(
                    context: context,
                    builder: (_) =>
                        const InstallToolDialog(tool: SetUpTab.installGit),
                  ),
                  tooltip: 'Git',
                ),
                VSeparators.normal(),
                // Java
                InstallationStatusTile(
                  status: _javaInstalled
                      ? InstallationStatus.done
                      : InstallationStatus.warning,
                  title:
                      _javaInstalled ? 'Java Installed' : 'Java Not Installed',
                  description:
                      'Java helps avoid common Android errors and is preferred for Android development.',
                  onDownload: () => showDialog(
                    context: context,
                    builder: (_) =>
                        const InstallToolDialog(tool: SetUpTab.installJava),
                  ),
                  tooltip: 'Java',
                ),
                VSeparators.normal(),
                RectangleButton(
                  width: double.infinity,
                  child: const Text('Close'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
    );
  }
}
