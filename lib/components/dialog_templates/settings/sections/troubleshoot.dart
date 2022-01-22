// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/components/dialog_templates/logs/build_logs.dart';
import 'package:fluttermatic/components/dialog_templates/other/reset_fluttermatic.dart';
import 'package:fluttermatic/core/libraries/constants.dart';
import 'package:fluttermatic/core/libraries/widgets.dart';

class TroubleShootSettingsSection extends StatefulWidget {
  const TroubleShootSettingsSection({Key? key}) : super(key: key);

  @override
  _TroubleShootSettingsSectionState createState() =>
      _TroubleShootSettingsSectionState();
}

class _TroubleShootSettingsSectionState
    extends State<TroubleShootSettingsSection> {
  bool _requireTruShoot = false;

  //Troubleshoot
  bool _all = false;
  bool _flutter = false;
  bool _studio = false;
  bool _vsc = false;

  void _checkTroubleShoot() {
    setState(() => _requireTruShoot = false);
    if (_all) {
      setState(() {
        _flutter = false;
        _studio = false;
        _vsc = false;
      });
    }
  }

  void _startTroubleshoot() {
    setState(() => _requireTruShoot = false);
    List<bool> _troubleshoot = <bool>[_all, _flutter, _studio, _vsc];
    if (!_troubleshoot.contains(true)) {
      setState(() => _requireTruShoot = true);
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          snackBarTile(context, 'This feature is not yet implemented'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return TabViewTabHeadline(
      title: 'Troubleshoot',
      allowContentScroll: false,
      content: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (_requireTruShoot)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: informationWidget(
                      'You need to choose at least one troubleshoot option.',
                      type: InformationType.error,
                    ),
                  ),
                CheckBoxElement(
                  onChanged: (bool? val) {
                    setState(() => _all = !_all);
                    _checkTroubleShoot();
                  },
                  value: _all,
                  text: 'All Applications',
                ),
                CheckBoxElement(
                  onChanged: (bool? val) {
                    setState(() {
                      _flutter = !_flutter;
                      _all = false;
                    });
                    _checkTroubleShoot();
                  },
                  value: _flutter,
                  text: 'Flutter',
                ),
                CheckBoxElement(
                  onChanged: (bool? val) {
                    setState(() {
                      _studio = !_studio;
                      _all = false;
                    });
                    _checkTroubleShoot();
                  },
                  value: _studio,
                  text: 'Android Studio',
                ),
                CheckBoxElement(
                  onChanged: (bool? val) {
                    setState(() {
                      _vsc = !_vsc;
                      _all = false;
                    });
                    _checkTroubleShoot();
                  },
                  value: _vsc,
                  text: 'Visual Studio Code',
                ),
                VSeparators.normal(),
                const Text('Options'),
                VSeparators.small(),
                Row(
                  children: <Widget>[
                    Container(
                      width: 2,
                      height: 60,
                      color: Colors.blueGrey.withOpacity(0.2),
                    ),
                    HSeparators.xSmall(),
                    Expanded(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 5,
                        children: <Widget>[
                          TextButton(
                            child: const Text('Troubleshoot'),
                            onPressed: _startTroubleshoot,
                          ),
                          TextButton(
                            child: const Text('Flutter Doctor'),
                            // TODO: Show flutter doctor result. Run doctor to get result.
                            onPressed: () {},
                          ),
                          TextButton(
                            child: const Text('Generate Report'),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => const BuildLogsDialog(),
                              );
                            },
                          ),
                          TextButton(
                            child: const Text('Reset all'),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => const ResetFlutterMaticDialog(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
