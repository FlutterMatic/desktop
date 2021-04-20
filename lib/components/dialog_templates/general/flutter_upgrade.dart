import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/dialog_header.dart';
import 'package:flutter_installer/components/widgets/activity_button.dart';
import 'package:flutter_installer/components/widgets/dialog_template.dart';
import 'package:flutter_installer/components/widgets/rectangle_button.dart';
import 'package:flutter_installer/services/checks.dart';
import 'package:flutter_installer/services/flutter_actions.dart';
import 'package:flutter_installer/utils/constants.dart';

class CheckFlutterVersionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future<void> _upgradeFlutter() async {
      CheckDependencies checkDependencies = CheckDependencies();
      BgActivityButton element = BgActivityButton(
        title: 'Upgrading your Flutter version',
        activityId: 'upgrading_flutter_version',
      );
      bgActivities.add(element);
      await FlutterActions().upgrade().then((value) {
        if (!value) {
          showDialog(
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
      });
      flutterInstalled = await checkDependencies.checkFlutter();
      javaInstalled = await checkDependencies.checkJava();
      vscInstalled = await checkDependencies.checkVSC();
      vscInsidersInstalled = await checkDependencies.checkVSCInsiders();
      studioInstalled = await checkDependencies.checkAndroidStudios();
      bgActivities.remove(element);
      await Navigator.pushNamed(context, PageRoutes.routeState);
    }

    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DialogHeader(title: 'Upgrade Flutter'),
          const SizedBox(height: 40),
          const Text(
            'Keeping Flutter up-to-date is a good idea since it helps with many things including performance improvments, bug fixes and new features.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
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
