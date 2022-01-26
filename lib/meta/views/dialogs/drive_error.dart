// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/warning_widget.dart';
import 'package:fluttermatic/core/notifiers/space.notifier.dart';
import 'package:fluttermatic/main.dart';

class SystemDriveErrorDialog extends StatelessWidget {
  const SystemDriveErrorDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: DialogTemplate(
        outerTapExit: false,
        child: Column(
          children: <Widget>[
            const DialogHeader(title: 'Fatal Drive Error'),
            informationWidget(
              'So, this error is sort of complicated. Every time you run FlutterMatic, we check your system drives to see which one is the most suitable drive for us to store your tools, data and app cache in. However, we\'ve noticed that your system drive does not match an expected drive. This is a fatal error, and we can\'t continue without it. Please contact your system administrator and ask them to check the system drive for FlutterMatic.',
            ),
            VSeparators.normal(),
            RoundContainer(
              color: Colors.blueGrey.withOpacity(0.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'System Drives: ${context.read<SpaceCheck>().conflictingDrives.join(', ')}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            VSeparators.normal(),
            RectangleButton(
              width: double.infinity,
              child: const Text('Restart FlutterMatic'),
              onPressed: () => RestartWidget.restartApp(context),
            ),
          ],
        ),
      ),
    );
  }
}
