// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/libraries/constants.dart';
import 'package:fluttermatic/core/libraries/services.dart';
import 'package:fluttermatic/core/libraries/utils.dart';

class LogViewBuilder extends StatelessWidget {
  final List<String> logs;
  const LogViewBuilder({
    Key? key,
    required this.logs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (_, int i) {
          try {
            if (logs[i].replaceAll(' ', '').isEmpty) {
              return VSeparators.small();
            }

            String _txt = logs[i];
            String _type = 'UNKNOWN';

            String _startTag = '<date_log>';
            String _endTag = '</date_log>';

            if (_txt.startsWith('INFO$_startTag')) {
              _type = 'INFO';
            } else if (_txt.startsWith('WARNING$_startTag')) {
              _type = 'WARNING';
            } else if (_txt.startsWith('ERROR$_startTag')) {
              _type = 'ERROR';
            }

            String _dateTxt = _txt.substring(
                _txt.indexOf(_startTag) + _startTag.length,
                _txt.contains(_endTag) ? _txt.indexOf(_endTag) : null);

            DateTime? _date = DateTime.tryParse(_dateTxt);

            String _log;

            if (_date == null) {
              _log = _txt;
            } else {
              _log = _txt
                  .substring(_txt.indexOf(_endTag) + _endTag.length)
                  .trimLeft();
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: SelectableText.rich(
                TextSpan(
                  children: <TextSpan>[
                    if (_type != 'UNKNOWN')
                      TextSpan(
                        text: '$_type ',
                        style: TextStyle(
                          color: _type == 'INFO'
                              ? kGreenColor
                              : _type == 'WARNING'
                                  ? kYellowColor
                                  : AppTheme.errorColor,
                        ),
                      ),
                    if (_date == null)
                      TextSpan(
                        text: _log,
                        style: const TextStyle(color: AppTheme.errorColor),
                      )
                    else
                      TextSpan(
                        text:
                            '${_date.hour < 10 ? '0${_date.hour}' : _date.hour}:${_date.minute < 10 ? '0${_date.minute}' : _date.minute}:${_date.second < 10 ? '0${_date.second}' : _date.second}\n$_log',
                      ),
                  ],
                ),
              ),
            );
          } catch (_, s) {
            logger.file(LogTypeTag.error,
                'Failed to parse workflow log line message for line $i',
                stackTraces: s);
            return Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: SelectableText(logs[i]),
            );
          }
        },
      ),
    );
  }
}
