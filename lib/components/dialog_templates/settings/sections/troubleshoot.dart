import 'package:flutter/material.dart';
import 'package:flutter_installer/components/widgets/inputs/check_box_element.dart';
import 'package:flutter_installer/components/widgets/buttons/rectangle_button.dart';
import 'package:flutter_installer/components/widgets/ui/round_container.dart';
import 'package:flutter_installer/components/widgets/ui/warning_widget.dart';
import 'package:flutter_installer/utils/constants.dart';

class TroubleShootSettingsSection extends StatefulWidget {
  @override
  _TroubleShootSettingsSectionState createState() =>
      _TroubleShootSettingsSectionState();
}

class _TroubleShootSettingsSectionState
    extends State<TroubleShootSettingsSection> {
  bool _requireTruShoot = false;

  //Troubleshoot
  bool truShootFullApp = false;
  bool truShootFlutter = false;
  bool truShootStudio = false;
  bool truShootVSC = false;

  void _checkTroubleShoot() {
    setState(() => _requireTruShoot = false);
    if (truShootFullApp) {
      setState(() {
        truShootFlutter = false;
        truShootStudio = false;
        truShootVSC = false;
      });
    }
  }

  void _startTroubleshoot() {
    setState(() => _requireTruShoot = false);
    if (truShootFlutter == false &&
        truShootFullApp == false &&
        truShootStudio == false &&
        truShootVSC == false) {
      setState(() => _requireTruShoot = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Troubleshooting',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 15),
        CheckBoxElement(
          onChanged: (val) {
            setState(() => truShootFullApp = !truShootFullApp);
            _checkTroubleShoot();
          },
          value: truShootFullApp,
          text: 'All Applications',
        ),
        CheckBoxElement(
          onChanged: (val) {
            setState(() {
              truShootFlutter = !truShootFlutter;
              truShootFullApp = false;
            });
            _checkTroubleShoot();
          },
          value: truShootFlutter,
          text: 'Flutter',
        ),
        CheckBoxElement(
          onChanged: (val) {
            setState(() {
              truShootStudio = !truShootStudio;
              truShootFullApp = false;
            });
            _checkTroubleShoot();
          },
          value: truShootStudio,
          text: 'Android Studio',
        ),
        CheckBoxElement(
          onChanged: (val) {
            setState(() {
              truShootVSC = !truShootVSC;
              truShootFullApp = false;
            });
            _checkTroubleShoot();
          },
          value: truShootVSC,
          text: 'Visual Studio Code',
        ),
        if (_requireTruShoot)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: warningWidget(
                'You need to choose at least one troubleshoot option.',
                Assets.error,
                kRedColor),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: RectangleButton(
            width: 150,
            onPressed: _startTroubleshoot,
            child: Text(
              'Start Troubleshoot',
              style: TextStyle(color: customTheme.textTheme.bodyText1!.color),
            ),
          ),
        ),
        const SizedBox(height: 10),
        RoundContainer(
          color: Colors.blueGrey.withOpacity(0.2),
          width: double.infinity,
          child: SelectableText(
            'FlutterMatic Installer Version $desktopVersion - Stable',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
