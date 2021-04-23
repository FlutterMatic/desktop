import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/dialog_header.dart';
import 'package:flutter_installer/components/widgets/activity_button.dart';
import 'package:flutter_installer/components/widgets/dialog_template.dart';
import 'package:flutter_installer/components/widgets/info_widget.dart';
import 'package:flutter_installer/components/widgets/rectangle_button.dart';
import 'package:flutter_installer/services/checks/win32Checks.dart';
import 'package:flutter_installer/services/flutter_actions.dart';
import 'package:flutter_installer/utils/constants.dart';

class CheckFlutterVersionDialog extends StatefulWidget {
  @override
  _CheckFlutterVersionDialogState createState() =>
      _CheckFlutterVersionDialogState();
}

bool? _updateResult;

class _CheckFlutterVersionDialogState extends State<CheckFlutterVersionDialog> {
  @override
  Widget build(BuildContext context) {
    Future<void> _upgradeFlutter() async {
      Win32Checks checkDependencies = Win32Checks();
      BgActivityButton element = BgActivityButton(
        title: 'Upgrading your Flutter version',
        activityId: 'upgrading_flutter_version',
      );
      bgActivities.add(element);
      await FlutterActions().upgrade().then((value) {
        setState(() => _updateResult = value);
      });
      flutterInstalled = await checkDependencies.checkFlutter();
      javaInstalled = await checkDependencies.checkJava();
      vscInstalled = await checkDependencies.checkVSC();
      vscInsidersInstalled = await checkDependencies.checkVSCInsiders();
      studioInstalled = await checkDependencies.checkAndroidStudios();
      bgActivities.remove(element);
      await Navigator.pushNamed(context, PageRoutes.routeState);
      if (!_updateResult!) {
        await showDialog(
          context: context,
          builder: (_) => DialogTemplate(
            child: Column(
              children: [
                DialogHeader(title: 'Latest Version'),
                const SizedBox(height: 20),
                const Text(
                    'You are already on the latest version of Flutter. You are good to go!'),
                const SizedBox(height: 20),
                RectangleButton(
                  width: double.infinity,
                  color: Colors.blueGrey,
                  splashColor: Colors.blueGrey.withOpacity(0.5),
                  focusColor: Colors.blueGrey.withOpacity(0.5),
                  hoverColor: Colors.grey.withOpacity(0.5),
                  highlightColor: Colors.blueGrey.withOpacity(0.5),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        );
      }
    }

    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DialogHeader(title: 'Upgrade Flutter'),
          const SizedBox(height: 20),
          const Text(
            'Keeping Flutter up-to-date is a good idea since it helps with many things including performance improvments, bug fixes and new features.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          infoWidget(
              'You can still use Flutter in your IDE while we update. You will be asked to restart any opened editors once the update is complete.'),
          const SizedBox(height: 10),
          RectangleButton(
            width: double.infinity,
            color: Colors.blueGrey,
            splashColor: Colors.blueGrey.withOpacity(0.5),
            focusColor: Colors.blueGrey.withOpacity(0.5),
            hoverColor: Colors.grey.withOpacity(0.5),
            highlightColor: Colors.blueGrey.withOpacity(0.5),
            onPressed: () {
              _upgradeFlutter();
              Navigator.pushNamed(context, PageRoutes.routeHome);
            },
            child: const Text('Upgrade Flutter'),
          ),
        ],
      ),
    );
  }
}
