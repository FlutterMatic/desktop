// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:url_launcher/url_launcher.dart';

// 🌎 Project imports:
import 'package:manager/components/dialog_templates/logs/build_logs.dart';
import 'package:manager/components/widgets/buttons/rectangle_button.dart';
import 'package:manager/components/widgets/ui/tab_view.dart';
import 'package:manager/components/widgets/ui/warning_widget.dart';
import 'package:manager/core/libraries/constants.dart';

class ReportAboutSection extends StatelessWidget {
  const ReportAboutSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabViewTabHeadline(
      title: 'Report',
      content: <Widget>[
        informationWidget(
          'If you are having any issues with the app, please report an issue on GitHub.',
          type: InformationType.warning,
        ),
        VSeparators.normal(),
        Align(
          alignment: Alignment.centerRight,
          child: RectangleButton(
            width: 100,
            child: const Text('Report'),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (_) => const BuildLogsDialog(),
              );

              await launch('https://github.com/FlutterMatic/desktop/issues');
              Navigator.pop(context);
            },
          ),
        )
      ],
    );
  }
}
