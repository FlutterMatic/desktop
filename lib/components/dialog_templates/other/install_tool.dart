// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/src/provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/app/constants/enum.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/spinner.dart';
import 'package:fluttermatic/core/services/checks/flutter.check.dart';
import 'package:fluttermatic/core/services/checks/git.check.dart';
import 'package:fluttermatic/core/services/checks/java.check.dart';
import 'package:fluttermatic/core/services/checks/studio.check.dart';
import 'package:fluttermatic/core/services/checks/vsc.check.dart';
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

  static const double _width = 500;

  final List<EditorType> _editors = <EditorType>[
    EditorType.vscode,
    EditorType.androidStudio,
  ];

  Widget _view = const Spinner();

  @override
  void initState() {
    switch (widget.tool) {
      case SetUpTab.gettingStarted:
        break;
      case SetUpTab.installFlutter:
        setState(() {
          _view = installFlutter(
            context,
            onInstall: () async {
              setState(() => _loading = true);

              await context
                  .read<FlutterNotifier>()
                  .checkFlutter(context, sdkData);

              setState(() {
                _isDone = true;
                _loading = false;
              });
            },
            onContinue: () => Navigator.pop(context),
          );
        });
        break;
      case SetUpTab.installEditor:
        setState(() {
          _view = SetUpInstallEditor(
            onInstall: () async {
              if (_editors.contains(EditorType.none)) {
                Navigator.pop(context);
                return;
              }

              setState(() => _loading = true);

              if (_editors.contains(EditorType.vscode)) {
                await context
                    .read<VSCodeNotifier>()
                    .checkVSCode(context, apiData);
              }

              if (_editors.contains(EditorType.androidStudio)) {
                await context
                    .read<AndroidStudioNotifier>()
                    .checkAStudio(context, apiData);
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
          );
        });
        break;
      case SetUpTab.installGit:
        setState(() {
          _view = installGit(
            context,
            onInstall: () async {
              setState(() => _loading = true);

              await context.read<GitNotifier>().checkGit(context, apiData);

              setState(() {
                _isDone = true;
                _loading = false;
              });
            },
            onContinue: () => Navigator.pop(context),
            doneInstalling: _isDone,
            isInstalling: _loading,
          );
        });

        break;
      case SetUpTab.installJava:
        setState(() {
          _view = installJava(
            context,
            onInstall: () async {
              setState(() => _loading = true);

              await context.read<JavaNotifier>().checkJava(context, apiData);

              setState(() {
                _isDone = true;
                _loading = false;
              });
            },
            onContinue: () => Navigator.pop(context),
            onSkip: () => Navigator.pop(context),
            doneInstalling: _isDone,
            isInstalling: _loading,
          );
        });

        break;
      case SetUpTab.restart:
        break;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_loading) {
          return false;
        }

        return true;
      },
      child: DialogTemplate(
        width: _width,
        canScroll: false,
        outerTapExit: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _view,
            if (!_loading && !_isDone && widget.tool != SetUpTab.installJava)
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
  }
}
