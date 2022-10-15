// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/general/app_theme.dart';

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

            String txt = logs[i];
            String type = 'UNKNOWN';

            String startTag = '<date_log>';
            String endTag = '</date_log>';

            if (txt.startsWith('INFO$startTag')) {
              type = 'INFO';
            } else if (txt.startsWith('WARNING$startTag')) {
              type = 'WARNING';
            } else if (txt.startsWith('ERROR$startTag')) {
              type = 'ERROR';
            }

            String dateTxt = txt.substring(
                txt.indexOf(startTag) + startTag.length,
                txt.contains(endTag) ? txt.indexOf(endTag) : null);

            DateTime? date = DateTime.tryParse(dateTxt);

            String log;

            if (date == null) {
              log = txt;
            } else {
              log =
                  txt.substring(txt.indexOf(endTag) + endTag.length).trimLeft();
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: SelectableText.rich(
                TextSpan(
                  children: <TextSpan>[
                    if (type != 'UNKNOWN')
                      TextSpan(
                        text: '$type ',
                        style: TextStyle(
                          color: type == 'INFO'
                              ? kGreenColor
                              : type == 'WARNING'
                                  ? kYellowColor
                                  : AppTheme.errorColor,
                        ),
                      ),
                    if (date == null)
                      TextSpan(
                        text: log,
                        style: const TextStyle(color: AppTheme.errorColor),
                      )
                    else
                      TextSpan(
                        text:
                            '${date.hour < 10 ? '0${date.hour}' : date.hour}:${date.minute < 10 ? '0${date.minute}' : date.minute}:${date.second < 10 ? '0${date.second}' : date.second}\n$log',
                      ),
                  ],
                ),
              ),
            );
          } catch (e, s) {
            logger.file(LogTypeTag.error,
                'Failed to parse workflow log line message for line $i',
                stackTrace: s);

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
