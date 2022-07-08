// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermatic/app/enum.dart';

// 🌎 Project imports:
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/core/notifiers/notifiers/checks/flutter.dart';
import 'package:fluttermatic/core/notifiers/notifiers/checks/git.dart';
import 'package:fluttermatic/core/notifiers/notifiers/checks/java.dart';
import 'package:fluttermatic/core/notifiers/notifiers/checks/studio.dart';
import 'package:fluttermatic/core/notifiers/notifiers/checks/vsc.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/meta/views/setup/sections/install_editor.dart';
import 'package:fluttermatic/meta/views/setup/sections/install_flutter.dart';
import 'package:fluttermatic/meta/views/setup/sections/install_git.dart';
import 'package:fluttermatic/meta/views/setup/sections/install_java.dart';

class InstallToolDialog extends StatefulWidget {
  final SetUpTab tool;

  const InstallToolDialog({
    Key? key,
    required this.tool,
  }) : super(key: key);

  @override
  _InstallToolDialogState createState() => _InstallToolDialogState();
}

class _InstallToolDialogState extends State<InstallToolDialog> {
  bool _isDone = false;
  bool _loading = false;

  final List<EditorType> _editors = <EditorType>[
    EditorType.vscode,
    EditorType.androidStudio,
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        FlutterNotifier flutterNotifier =
            ref.watch(flutterNotifierController.notifier);

        GitNotifier gitNotifier = ref.watch(gitNotifierController.notifier);

        JavaNotifier javaNotifier = ref.watch(javaNotifierController.notifier);

        AndroidStudioNotifier asNotifier =
            ref.watch(androidStudioNotifierController.notifier);

        VSCodeNotifier vscNotifier = ref.watch(vscNotifierController.notifier);

        return WillPopScope(
          onWillPop: () => Future.value(!_loading),
          child: DialogTemplate(
            width: 500,
            canScroll: false,
            outerTapExit: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (widget.tool == SetUpTab.installFlutter)
                  installFlutter(
                    context,
                    onInstall: () async {
                      setState(() => _loading = true);

                      await flutterNotifier.checkFlutter();

                      setState(() {
                        _isDone = true;
                        _loading = false;
                      });
                    },
                    onContinue: () => Navigator.pop(context),
                  )
                else if (widget.tool == SetUpTab.installEditor)
                  SetUpInstallEditor(
                    onInstall: () async {
                      if (_editors.contains(EditorType.none)) {
                        Navigator.pop(context);
                        return;
                      }

                      setState(() => _loading = true);

                      if (_editors.contains(EditorType.vscode)) {
                        await vscNotifier.checkVSCode();
                      }

                      if (_editors.contains(EditorType.androidStudio)) {
                        await asNotifier.checkAStudio();
                      }

                      setState(() {
                        _isDone = true;
                        _loading = false;
                      });
                    },
                    onContinue: () => Navigator.pop(context),
                    doneInstalling: _isDone,
                    isInstalling: _loading,
                    onEditorTypeChanged: (List<EditorType> editors) {
                      setState(() {
                        _editors.clear();
                        _editors.addAll(editors);
                      });
                    },
                  )
                else if (widget.tool == SetUpTab.installGit)
                  installGit(
                    context,
                    onInstall: () async {
                      setState(() => _loading = true);

                      await gitNotifier.checkGit();

                      setState(() {
                        _isDone = true;
                        _loading = false;
                      });
                    },
                    onContinue: () => Navigator.pop(context),
                    doneInstalling: _isDone,
                    isInstalling: _loading,
                  )
                else if (widget.tool == SetUpTab.installJava)
                  installJava(
                    context,
                    onInstall: () async {
                      setState(() => _loading = true);

                      await javaNotifier.checkJava();

                      setState(() {
                        _isDone = true;
                        _loading = false;
                      });
                    },
                    onContinue: () => Navigator.pop(context),
                    onSkip: () => Navigator.pop(context),
                    doneInstalling: _isDone,
                    isInstalling: _loading,
                  ),
                if (!_loading &&
                    !_isDone &&
                    widget.tool != SetUpTab.installJava)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
