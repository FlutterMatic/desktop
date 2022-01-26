// 🎯 Dart imports:
import 'dart:io';
import 'dart:isolate';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pub_semver/src/version.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/app/constants/enum.dart';
import 'package:fluttermatic/app/constants/shared_pref.dart';
import 'package:fluttermatic/components/dialog_templates/flutter/flutter_upgrade.dart';
import 'package:fluttermatic/components/dialog_templates/other/install_tool.dart';
import 'package:fluttermatic/components/dialog_templates/project/new_project.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/shimmer.dart';
import 'package:fluttermatic/core/models/check_response.model.dart';
import 'package:fluttermatic/core/services/checks/check.services.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';
import 'package:fluttermatic/meta/utils/shared_pref.dart';
import 'package:fluttermatic/meta/utils/time_ago.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/elements/hover_info_tile.dart';

Future<void> _check(List<dynamic> data) async {
  SendPort _port = data[0];
  String _logPath = data[1];

  ServiceCheckResponse _result =
      await CheckServices.checkFlutter(Directory(_logPath));

  _port.send(<dynamic>[
    _result.version?.toString(),
    _result.channel,
  ]);
}

class HomeFlutterVersionTile extends StatefulWidget {
  const HomeFlutterVersionTile({Key? key}) : super(key: key);

  @override
  _HomeFlutterVersionStateTile createState() => _HomeFlutterVersionStateTile();
}

class _HomeFlutterVersionStateTile extends State<HomeFlutterVersionTile> {
  final ReceivePort _port = ReceivePort('FLUTTER_HOME_ISOLATE_PORT');

  Version? _version;
  String _channel = '...';

  bool _doneLoading = false;
  bool _listening = false;

  Future<void> _load() async {
    while (mounted) {
      Directory _logPath = await getApplicationSupportDirectory();
      await Isolate.spawn(_check, <dynamic>[_port.sendPort, _logPath.path]);

      if (mounted && !_listening) {
        _port.listen((dynamic data) {
          setState(() => _listening = true);
          if (mounted) {
            setState(() {
              _doneLoading = true;
              if (data[0] == null) {
                _version = null;
              } else {
                _version = Version?.parse(data[0] as String);
              }
              _channel = data[1] as String? ?? '...';
            });
          }
        });
      }

      await Future<void>.delayed(const Duration(minutes: 30));
    }
  }

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _port.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RoundContainer(
      child: Shimmer.fromColors(
        enabled: !_doneLoading,
        child: IgnorePointer(
          ignoring: !_doneLoading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  SvgPicture.asset(Assets.flutter, height: 20),
                  HSeparators.small(),
                  Expanded(
                    child: Text(
                      'Flutter - ${_version ?? '...'}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  HSeparators.xSmall(),
                  if (!_doneLoading)
                    const Text('- ')
                  else if (_version == null)
                    SvgPicture.asset(Assets.error, height: 20)
                  else
                    SvgPicture.asset(Assets.done, height: 20),
                ],
              ),
              VSeparators.normal(),
              HoverMessageWithIconAction(
                message: _doneLoading
                    ? (_version == null
                        ? 'Flutter is not installed on your device'
                        : 'Flutter is up to date on channel $_channel ')
                    : '...',
                icon: Icon(
                    _doneLoading
                        ? (_version == null ? Icons.error : Icons.check_rounded)
                        : Icons.lock_clock,
                    color: _doneLoading
                        ? (_version == null ? AppTheme.errorColor : kGreenColor)
                        : kYellowColor,
                    size: 15),
              ),
              VSeparators.normal(),
              if (_doneLoading && _version != null ||
                  !_doneLoading) ...<Widget>[
                HoverMessageWithIconAction(
                  message: SharedPref()
                          .pref
                          .containsKey(SPConst.lastFlutterUpdateCheck)
                      ? 'Checked for new updates ${getTimeAgo(DateTime.parse(SharedPref().pref.getString(SPConst.lastFlutterUpdateCheck) ?? DateTime.now().toString()))}'
                      : 'Never checked for new updates before',
                  icon: const Icon(Icons.refresh_rounded,
                      color: kGreenColor, size: 15),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const UpdateFlutterDialog(),
                    );
                  },
                ),
                VSeparators.normal(),
                HoverMessageWithIconAction(
                  message: SharedPref()
                          .pref
                          .containsKey(SPConst.lastFlutterUpdate)
                      ? 'Last updated ${getTimeAgo(DateTime.parse(SharedPref().pref.getString(SPConst.lastFlutterUpdate) ?? DateTime.now().toString()))}'
                      : 'Never updated before',
                  icon: const Icon(Icons.check_rounded,
                      color: kGreenColor, size: 15),
                ),
                VSeparators.normal(),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: RectangleButton(
                        child: const Text('Check Updates'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const UpdateFlutterDialog(),
                          );
                        },
                      ),
                    ),
                    HSeparators.normal(),
                    Expanded(
                      child: RectangleButton(
                        child: const Text('Create New'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const NewProjectDialog(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ] else
                RectangleButton(
                  width: double.infinity,
                  child: const Text('Install Flutter'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const InstallToolDialog(
                          tool: SetUpTab.installFlutter),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
