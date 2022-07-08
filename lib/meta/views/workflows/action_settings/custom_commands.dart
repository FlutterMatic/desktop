// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/theme.dart';
import 'package:fluttermatic/core/notifiers/out.dart';

class CustomCommandsWorkflowActionsConfig extends StatefulWidget {
  final List<String> commands;
  final Function(List<String> commands) onCommandsChanged;

  const CustomCommandsWorkflowActionsConfig({
    Key? key,
    required this.commands,
    required this.onCommandsChanged,
  }) : super(key: key);

  @override
  State<CustomCommandsWorkflowActionsConfig> createState() =>
      _CustomCommandsWorkflowActionsConfigState();
}

class _CustomCommandsWorkflowActionsConfigState
    extends State<CustomCommandsWorkflowActionsConfig> {
  late final List<String> _commands = widget.commands;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        ThemeState themeState = ref.watch(themeStateController);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                      'Add a set of commands. This will run in the order you add.'),
                ),
                HSeparators.small(),
                SquareButton(
                  tooltip: 'Add',
                  color: Colors.transparent,
                  icon: const Icon(Icons.add_rounded),
                  onPressed: () {
                    if (!_commands.contains('')) {
                      setState(() => _commands.add(''));
                    } else {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        snackBarTile(
                          context,
                          'There is already an empty command. Try filling it first.',
                          type: SnackBarType.warning,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            VSeparators.small(),
            RoundContainer(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        _commands.length.toString(),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      VSeparators.xSmall(),
                      Text(
                        'command${_commands.length == 1 ? '' : 's'}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  HSeparators.normal(),
                  Expanded(
                    child: Text(
                      'We will run these commands in order. Make sure you add each command in the order you want them to be executed.\n\nThe directory these commands will run is the directory of where the pubspec.yaml file is located. To change path, make use of the CD command.',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                ],
              ),
            ),
            for (int i = 0; i < _commands.length; i++)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: RoundContainer(
                          padding: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: TextFormField(
                              initialValue: _commands[i],
                              style: TextStyle(
                                color: (themeState.isDarkTheme
                                        ? Colors.white
                                        : Colors.black)
                                    .withOpacity(0.8),
                              ),
                              cursorRadius: const Radius.circular(5),
                              onChanged: (String val) {
                                setState(() {
                                  _commands[i] = val.trim();
                                  // Remove where the command is empty
                                  _commands.removeWhere((_) => _.isEmpty);
                                  if (val.trim().isEmpty) {
                                    _commands.add('');
                                  }
                                });
                                widget.onCommandsChanged(_commands
                                    .where((_) => _.trim().isNotEmpty)
                                    .toList());
                              },
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                  color: (themeState.isDarkTheme
                                          ? Colors.white
                                          : Colors.black)
                                      .withOpacity(0.6),
                                  fontSize: 14,
                                ),
                                hintText: 'Type command',
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(10),
                                isCollapsed: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    HSeparators.small(),
                    RoundContainer(
                      height: 45,
                      width: 45,
                      padding: EdgeInsets.zero,
                      child: Center(child: _getSuffixIcon(_commands[i])),
                    ),
                    HSeparators.small(),
                    SquareButton(
                      size: 45,
                      tooltip: 'Remove',
                      icon: const Icon(Icons.remove_rounded, size: 15),
                      onPressed: () {
                        setState(() => _commands.removeAt(i));
                        widget.onCommandsChanged(_commands
                            .where((_) => _.trim().isNotEmpty)
                            .toList());
                      },
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

Widget _getSuffixIcon(String command) {
  String x = command.toLowerCase().trim();

  if (x.startsWith('cd')) {
    return const Tooltip(
      message: 'Directory',
      waitDuration: Duration(seconds: 1),
      child: Text('CD'),
    );
  } else if (x.startsWith('flutter')) {
    return Tooltip(
      message: 'Flutter',
      waitDuration: const Duration(seconds: 1),
      child: SvgPicture.asset(Assets.flutter, height: 18),
    );
  } else if (x.startsWith('dart')) {
    return Tooltip(
      message: 'Dart',
      waitDuration: const Duration(seconds: 1),
      child: SvgPicture.asset(Assets.dart, height: 18),
    );
  } else if (x.startsWith('git')) {
    return Tooltip(
      message: 'Git',
      waitDuration: const Duration(seconds: 1),
      child: SvgPicture.asset(Assets.git, height: 18),
    );
  } else {
    return const Tooltip(
      message: 'Command',
      waitDuration: Duration(seconds: 1),
      child: Text('CMD'),
    );
  }
}
