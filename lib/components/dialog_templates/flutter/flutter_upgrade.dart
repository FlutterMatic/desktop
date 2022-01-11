// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/widgets.dart';
import '../dialog_header.dart';

class UpgradeFlutterDialog extends StatefulWidget {
  const UpgradeFlutterDialog({Key? key}) : super(key: key);

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
            onPressed: _upgradeFlutter,
            child: const Text('Upgrade Flutter'),
          ),
        ],
      ),
    );
  }
}
