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
import 'package:fluttermatic/components/dialog_templates/other/install_tool.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/beta_tile.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/shimmer.dart';
import 'package:fluttermatic/core/models/check_response.model.dart';
import 'package:fluttermatic/core/services/checks/check.services.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/shared_pref.dart';
import 'package:fluttermatic/meta/utils/time_ago.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/elements/hover_info_tile.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/elements/tool_error.dart';

Future<void> _check(List<dynamic> data) async {
  SendPort _port = data[0];
  String _logPath = data[1];

  ServiceCheckResponse _result =
      await CheckServices.checkGit(Directory(_logPath));

  _port.send(<dynamic>[
    _result.version?.toString(),
  ]);
}

class HomeGitVersionTile extends StatefulWidget {
  const HomeGitVersionTile({Key? key}) : super(key: key);

  @override
  _HomeGitVersionStateTile createState() => _HomeGitVersionStateTile();
}

class _HomeGitVersionStateTile extends State<HomeGitVersionTile> {
  final ReceivePort _port = ReceivePort('GIT_HOME_ISOLATE_PORT');

  Version? _version;

  // Utils
  bool _error = false;
  bool _doneLoading = false;
  bool _listening = false;

  Future<void> _load() async {
    while (mounted) {
      Directory _logPath = await getApplicationSupportDirectory();
      await Isolate.spawn(_check, <dynamic>[_port.sendPort, _logPath.path])
          .timeout(const Duration(minutes: 1), onTimeout: () async {
        await logger.file(LogTypeTag.error, 'Git version check timeout');
        setState(() => _error = true);

        return Isolate.current;
      });

      if (mounted && !_listening) {
        _port.listen((dynamic data) {
          setState(() => _listening = true);
          if (mounted) {
            setState(() {
              _error = false;
              _doneLoading = true;
              if (data[0] == null) {
                _version = null;
              } else {
                _version = Version?.parse(data[0] as String);
              }
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
    if (_error) {
      return const HomeToolErrorTile(toolName: 'Git');
    }
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
                  SvgPicture.asset(Assets.git, height: 20),
                  HSeparators.small(),
                  Expanded(
                    child: Text(
                      'Git - ${_version ?? '...'}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const StageTile(stageType: StageType.prerelease),
                  HSeparators.normal(),
                  if (!_doneLoading)
                    const Text('- ')
                  else if (_version == null)
                    SvgPicture.asset(Assets.error, height: 20)
                  else
                    SvgPicture.asset(Assets.done, height: 20),
                ],
              ),
              VSeparators.normal(),
              if (_doneLoading && _version != null ||
                  !_doneLoading) ...<Widget>[
                HoverMessageWithIconAction(
                  message: SharedPref()
                          .pref
                          .containsKey(SPConst.lastGitUpdateCheck)
                      ? 'Checked for new updates ${getTimeAgo(DateTime.parse(SharedPref().pref.getString(SPConst.lastGitUpdateCheck) ?? DateTime.now().toString()))}'
                      : 'Never checked for new updates before',
                  icon: const Icon(Icons.refresh_rounded,
                      color: kGreenColor, size: 15),
                  onPressed: () {},
                  // TODO: Show update git dialog
                ),
                VSeparators.normal(),
                HoverMessageWithIconAction(
                  message: SharedPref().pref.containsKey(SPConst.lastGitUpdate)
                      ? 'Last updated ${getTimeAgo(DateTime.parse(SharedPref().pref.getString(SPConst.lastGitUpdate) ?? DateTime.now().toString()))}'
                      : 'Never updated before',
                  icon: const Icon(Icons.check_rounded,
                      color: kGreenColor, size: 15),
                ),
                VSeparators.normal(),
                RectangleButton(
                  child: const Text('Check Updates'),
                  width: double.infinity,
                  onPressed: () {},
                  // TODO: Show update git dialog
                ),
              ] else
                RectangleButton(
                  width: double.infinity,
                  child: const Text('Install Git'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) =>
                          const InstallToolDialog(tool: SetUpTab.installGit),
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
