import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/dialog_header.dart';
import 'package:flutter_installer/components/widgets/activity_button.dart';
import 'package:flutter_installer/components/widgets/dialog_template.dart';
import 'package:flutter_installer/components/widgets/info_widget.dart';
import 'package:flutter_installer/components/widgets/rectangle_button.dart';
import 'package:flutter_installer/services/apiServices/api.dart';
import 'package:flutter_installer/services/other.dart';
import 'package:flutter_installer/services/flutter_actions.dart';
import 'package:flutter_installer/utils/constants.dart';

class UpgradeFlutterDialog extends StatefulWidget {
  @override
  _UpgradeFlutterDialogState createState() => _UpgradeFlutterDialogState();
}

bool? _updateResult = false;

class _UpgradeFlutterDialogState extends State<UpgradeFlutterDialog> {
  @override
  Widget build(BuildContext context) {
    Future<void> _upgradeFlutter() async {
      BgActivityButton element = BgActivityButton(
        title: 'Upgrading your Flutter version',
        activityId: 'upgrading_flutter_version',
      );
      bgActivities.add(element);
      await apiCalls.flutterAPICall().then((apiData) async {
        flutterAPIVersion = apiData.releases![0]!.version;
        if (await compareVersion(
            latestVersion: flutterAPIVersion!,
            previousVersion: flutterVersion!)) {
          await flutterActions.upgrade().then((value) {
            _updateResult = value;
          });
        } else {
          _updateResult = false;
        }
      });
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
              Navigator.pop(context);
            },
            child: const Text('Upgrade Flutter'),
          ),
        ],
      ),
    );
  }
}
