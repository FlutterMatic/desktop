import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/dialog_header.dart';
import 'package:flutter_installer/components/dialog_templates/dialogs/change_channel.dart';
import 'package:flutter_installer/components/dialog_templates/dialogs/flutter_upgrade.dart';
import 'package:flutter_installer/components/dialog_templates/dialogs/new_project.dart';
import 'package:flutter_installer/components/widgets/dialog_template.dart';
import 'package:flutter_installer/components/widgets/rectangle_button.dart';
import 'package:flutter_installer/components/widgets/round_container.dart';
import 'package:flutter_installer/components/widgets/text_field.dart';
import 'package:flutter_installer/components/widgets/warning_widget.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'package:process_run/shell.dart';
import 'dart:io';

class RunCommandDialog extends StatefulWidget {
  @override
  _RunCommandDialogState createState() => _RunCommandDialogState();
}

class _RunCommandDialogState extends State<RunCommandDialog> {
  final TextEditingController _commandController = TextEditingController();

  // Utils
  bool _loading = false;
  bool _showTypeRequest = false;
  String? _trimmedCommand;

  String? _commandResult;

  Future<void> _runCommand() async {
    _commandController.text = _commandController.text.replaceAll('flutter', '');
    setState(() {
      _commandResult = null;
      _showTypeRequest = false;
      _trimmedCommand = _commandController.text.replaceAll(' ', '');
    });
    if (_trimmedCommand == 'create.' || _trimmedCommand == 'createapp') {
      Navigator.pop(context);
      await showDialog(context: context, builder: (_) => NewProjectDialog());
    } else if (_trimmedCommand == 'upgrade') {
      Navigator.pop(context);
      await showDialog(
          context: context, builder: (_) => UpgradeFlutterDialog());
    } else if (_trimmedCommand == 'channelmaster' ||
        _trimmedCommand == 'channelstable' ||
        _trimmedCommand == 'channeldev' ||
        _trimmedCommand == 'channelbeta') {
      Navigator.pop(context);
      await showDialog(context: context, builder: (_) => ChangeChannelDialog());
    } else if (_commandController.text.isNotEmpty) {
      setState(() => _loading = true);
      Shell _shell = Shell();
      await _shell
          .run('flutter ' + _commandController.text)
          .then((value) => setState(() {
                _commandResult = value.outText;
              }))
          .catchError((e) {
        setState(() =>
          _commandResult =
              '"${_commandController.text}" is not recognized as a flutter command. Run help to see all commands. \n\nPlease note you can only run Flutter commands. To run commands other than Flutter commands, use your ${Platform.isMacOS ? 'macOS' : Platform.isWindows ? 'Windows' : 'Linux'} terminal.'
        );
      });
      setState(() => _loading = false);
    } else {
      setState(() => _showTypeRequest = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return DialogTemplate(
      child: Column(
        children: [
          DialogHeader(title: 'Run Flutter Command'),
          const SizedBox(height: 20),
          CustomTextField(
            hintText: 'Type Command',
            readOnly: _loading,
            controller: _commandController,
          ),
          if (_commandResult != null) const SizedBox(height: 15),
          if (_showTypeRequest)
            warningWidget(
                'Please type in a flutter command.', Assets.error, kRedColor),
          if (_commandResult != null)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250),
              child: RoundContainer(
                width: double.infinity,
                color: Colors.blueGrey.withOpacity(0.2),
                child: Scrollbar(
                  child: SelectableText(_commandResult!),
                ),
              ),
            ),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.centerRight,
            child: RectangleButton(
              onPressed: _loading ? null : _runCommand,
              width: 100,
              disableColor: Colors.blueGrey.withOpacity(0.2),
              loading: _loading,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Run',
                    style: TextStyle(
                        color: customTheme.textTheme.bodyText1!.color!),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.play_arrow_rounded, color: kGreenColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
