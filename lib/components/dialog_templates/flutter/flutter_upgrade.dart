import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/dialog_header.dart';
import 'package:flutter_installer/components/widgets/ui/activity_tile.dart';
import 'package:flutter_installer/components/widgets/ui/dialog_template.dart';
import 'package:flutter_installer/components/widgets/ui/info_widget.dart';
import 'package:flutter_installer/components/widgets/buttons/rectangle_button.dart';
import 'package:flutter_installer/models/flutter_api.dart';
import 'package:flutter_installer/services/apiServices/api.dart';
import 'package:flutter_installer/services/other.dart';
import 'package:flutter_installer/services/flutter_actions.dart';
import 'package:flutter_installer/utils/constants.dart';

class UpgradeFlutterDialog extends StatefulWidget {
  @override
  _UpgradeFlutterDialogState createState() => _UpgradeFlutterDialogState();
}

class _UpgradeFlutterDialogState extends State<UpgradeFlutterDialog> {
  Future<void> _upgradeFlutter() async {
    Navigator.pop(context);
    BgActivityTile _element = BgActivityTile(
      title: 'Upgrading your Flutter version',
      activityId: 'upgrading_flutter_version',
    );
    bgActivities.add(_element);
    FlutterReleases _result =
        await flutterApi.flutterAPICall().then((apiData) => apiData);
    String? flutterAPIVersion = _result.releases![0]!.version;
    bool _versionisGreater = await compareVersion(
        latestVersion: flutterAPIVersion!, previousVersion: flutterVersion!);
    // There is a new version
    if (_versionisGreater) {
      await FlutterActions().upgrade();
    }
    // No new version - latest already
    else {
      debugPrint('Latest Flutter version already');
    }
    bgActivities.remove(_element);
  }

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
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
            onPressed: _upgradeFlutter,
            child: const Text('Upgrade Flutter'),
          ),
        ],
      ),
    );
  }
}
