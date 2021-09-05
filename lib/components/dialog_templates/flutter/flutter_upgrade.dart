import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/widgets.dart';

import '../dialog_header.dart';

class UpgradeFlutterDialog extends StatefulWidget {
  @override
  _UpgradeFlutterDialogState createState() => _UpgradeFlutterDialogState();
}

class _UpgradeFlutterDialogState extends State<UpgradeFlutterDialog> {
  /// TODO: Upgrade Flutter when is requested. Ignore the request and say that Flutter is already up to date if current version is equal to the latest version.
  Future<void> _upgradeFlutter() async {
    Navigator.pop(context);
    BgActivityTile _activityElement = const BgActivityTile(
      title: 'Upgrading your Flutter version',
      activityId: 'upgrading_flutter_version',
    );
    bgActivities.add(_activityElement);
    bgActivities.remove(_activityElement);
  }

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const DialogHeader(title: 'Upgrade Flutter'),
          const Text(
            'Keeping Flutter up-to-date is a good idea since it helps with many things including performance improvements, bug fixes and new features.',
            textAlign: TextAlign.center,
          ),
          VSeparators.small(),
          infoWidget(context,
              'You can still use Flutter in your IDE while we update. You will be asked to restart any opened editors once the update is complete.'),
          VSeparators.small(),
          RectangleButton(
            width: double.infinity,
            color: Colors.blueGrey,
            splashColor: Colors.blueGrey.withOpacity(0.5),
            focusColor: Colors.blueGrey.withOpacity(0.5),
            hoverColor: Colors.grey.withOpacity(0.5),
            highlightColor: Colors.blueGrey.withOpacity(0.5),
            onPressed: _upgradeFlutter,
            child: const Text('Upgrade Flutter'),
          ),
        ],
      ),
    );
  }
}
