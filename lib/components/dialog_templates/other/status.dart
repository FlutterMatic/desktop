// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/enum.dart';
import 'package:fluttermatic/bin/check_services.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/dialog_templates/other/install_tool.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/installation_status.dart';
import 'package:fluttermatic/components/widgets/ui/shimmer.dart';
import 'package:fluttermatic/core/notifiers/out.dart';

class StatusDialog extends ConsumerWidget {
  const StatusDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CheckServicesState state = ref.watch(checkServicesStateNotifier);
    CheckServicesNotifier notifier =
        ref.watch(checkServicesStateNotifier.notifier);

    return DialogTemplate(
      child: state.loading
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
                const DialogHeader(title: 'Status'),
                // Dart
                InstallationStatusTile(
                  status: notifier.dart?.version != null
                      ? InstallationStatus.done
                      : InstallationStatus.error,
                  title: notifier.dart?.version != null
                      ? 'Dart Installed'
                      : 'Dart Not Installed',
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
                  status: notifier.flutter?.version != null
                      ? InstallationStatus.done
                      : InstallationStatus.error,
                  title: notifier.flutter?.version != null
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
                  status: notifier.studio?.version != null
                      ? InstallationStatus.done
                      : InstallationStatus.warning,
                  title: notifier.studio?.version != null
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
                  status: notifier.vsCode?.version != null
                      ? InstallationStatus.done
                      : InstallationStatus.warning,
                  title: notifier.vsCode?.version != null
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
                  status: notifier.git?.version != null
                      ? InstallationStatus.done
                      : InstallationStatus.error,
                  title: notifier.git?.version != null
                      ? 'Git Installed'
                      : 'Git Not Installed',
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
                  status: notifier.java?.version != null
                      ? InstallationStatus.done
                      : InstallationStatus.warning,
                  title: notifier.java?.version != null
                      ? 'Java Installed'
                      : 'Java Not Installed',
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
