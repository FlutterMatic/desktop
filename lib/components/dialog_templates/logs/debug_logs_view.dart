// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:path_provider/path_provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/components/widgets/ui/stage_tile.dart';
import 'package:fluttermatic/core/services/logs.dart';

class ViewDebugLogsDialog extends StatefulWidget {
  const ViewDebugLogsDialog({Key? key}) : super(key: key);

  @override
  State<ViewDebugLogsDialog> createState() => _ViewDebugLogsDialogState();
}

class _ViewDebugLogsDialogState extends State<ViewDebugLogsDialog> {
  List<String> _logs = <String>[];

  Future<void> _init() async {
    List<String> lines =
        await (await Logger.currentFile(await getApplicationSupportDirectory()))
            .readAsLines();

    setState(() => _logs = lines);
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          const DialogHeader(
            title: 'FlutterMatic Debug Logs',
            leading: StageTile(stageType: StageType.beta),
          ),
          if (_logs.isEmpty)
            const RoundContainer(
              width: double.infinity,
              child: Text('No logs found. Nothing has been logged yet.'),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (_, int i) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      VSeparators.xSmall(),
                      SelectableText(_logs[i]),
                      VSeparators.xSmall(),
                      const RoundContainer(
                        height: 1,
                        width: double.infinity,
                        child: SizedBox.shrink(),
                      ),
                    ],
                  );
                },
              ),
            ),
          VSeparators.normal(),
          Row(
            children: <Widget>[
              Tooltip(
                message: 'Copy debug logs',
                waitDuration: const Duration(seconds: 1),
                child: RectangleButton(
                  width: 50,
                  child: const Icon(Icons.copy_all_rounded, size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _logs.join('\n')));
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
                      context,
                      'Copied debug logs to clipboard',
                      type: SnackBarType.done,
                    ));
                  },
                ),
              ),
              HSeparators.small(),
              Expanded(
                child: RectangleButton(
                  child: const Text('Close'),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
