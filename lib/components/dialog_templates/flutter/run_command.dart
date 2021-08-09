import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/components/dialog_templates/projects/new_project/new_project.dart';
import 'package:manager/components/widgets/buttons/rectangle_button.dart';
import 'package:manager/components/widgets/inputs/check_box_element.dart';
import 'package:manager/components/widgets/inputs/text_field.dart';
import 'package:manager/components/widgets/ui/dialog_template.dart';
import 'package:manager/components/widgets/ui/round_container.dart';
import 'package:manager/components/widgets/ui/spinner.dart';
import 'package:manager/components/widgets/ui/warning_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'change_channel.dart';
import 'flutter_upgrade.dart';

class RunCommandDialog extends StatefulWidget {
  @override
  _RunCommandDialogState createState() => _RunCommandDialogState();
}

class _RunCommandDialogState extends State<RunCommandDialog> {
  final TextEditingController _commandController = TextEditingController();

  // Utils
  late SharedPreferences _pref;
  bool _loading = false;
  bool _showTypeRequest = false;
  String? _trimmedCommand;

  bool? _preferVerbose;

  String? _commandResult;

  Future<void> _runCommand() async {
    String _command = 'flutter ' +
        _commandController.text
            .replaceAll('-v', '')
            .replaceAll('-verbose', '') +
        (_preferVerbose! ? ' -v' : '');
    _commandController.text = _commandController.text.replaceAll('flutter', '');
    setState(() {
      _commandResult = null;
      _showTypeRequest = false;
      _trimmedCommand = _commandController.text.replaceAll(' ', '');
    });
    if (_trimmedCommand == 'create.' || _trimmedCommand == 'create') {
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
      await shell
          .run(_command)
          .then((List<ProcessResult> value) => setState(() {
                _commandResult = value.first.stdout;
              }))
          .catchError((dynamic e) {
        setState(() => _commandResult =
            '"${_commandController.text.length > 50 ? _commandController.text.substring(0, 50) + '...' : _commandController.text}" is not recognized as a flutter command. Run help to see all commands. \n\nPlease note you can only run Flutter commands. To run commands other than Flutter commands, use your ${Platform.isMacOS ? 'macOS' : Platform.isWindows ? 'Windows' : 'Linux'} terminal.');
      });
      setState(() => _loading = false);
    } else {
      setState(() => _showTypeRequest = true);
    }
  }

  Future<void> _loadPref() async {
    _pref = await SharedPreferences.getInstance();
    if (_pref.containsKey('prefer_verbose')) {
      setState(() => _preferVerbose = _pref.getBool('prefer_verbose'));
    } else {
      setState(() => _preferVerbose = false);
    }
  }

  @override
  void initState() {
    _loadPref();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          const DialogHeader(title: 'Run Flutter Command'),
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
              constraints: const BoxConstraints(maxHeight: 350),
              child: RoundContainer(
                width: double.infinity,
                color: Colors.blueGrey.withOpacity(0.2),
                child: Scrollbar(
                  child: SelectableText(
                    _commandResult!.isEmpty
                        ? 'Something unexpected happened. Most likely this command expects an input. Currently we only support one way command.'
                        : _commandResult!
                            .replaceAll('âˆš', '✔') // Format checks
                            .replaceAll('âœ“', '✔') // Format checks
                            .replaceAll('!', '❗') // Format warnings
                            .replaceAll('âœ—', '❌') // Format errors
                            .replaceAll('ðŸ”¨', '🔨') // Format builds
                            .replaceAll(
                              'â€¢',
                              '-',
                            ),
                  ), // Format points
                ),
              ),
            ),
          const SizedBox(height: 15),
          Row(
            children: <Widget>[
              if (_preferVerbose == null)
                Expanded(
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                          height: 20, width: 20, child: Spinner(thickness: 2)),
                      const Spacer(),
                    ],
                  ),
                )
              else
                Expanded(
                  child: CheckBoxElement(
                    onChanged: (bool? val) async {
                      setState(() => _preferVerbose = val);
                      _pref = await SharedPreferences.getInstance();
                      await _pref.setBool('prefer_verbose', val!);
                    },
                    value: _preferVerbose!,
                    text: 'Run with verbose',
                  ),
                ),
              RectangleButton(
                onPressed: _loading ? null : _runCommand,
                width: 100,
                disableColor: Colors.blueGrey.withOpacity(0.2),
                loading: _loading,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
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
            ],
          ),
        ],
      ),
    );
  }
}
