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
import 'package:fluttermatic/components/dialog_templates/other/install_tool.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/shimmer.dart';
import 'package:fluttermatic/components/widgets/ui/stage_tile.dart';
import 'package:fluttermatic/core/models/check_response.model.dart';
import 'package:fluttermatic/core/services/checks/check.services.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/elements/hover_info_tile.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/elements/tool_error.dart';

Future<void> _check(List<dynamic> data) async {
  SendPort _port = data[0];
  String _logPath = data[1];

  ServiceCheckResponse _result =
      await CheckServices.checkJava(Directory(_logPath));

  _port.send(<dynamic>[
    _result.version?.toString(),
  ]);
}

class HomeJavaVersionTile extends StatefulWidget {
  const HomeJavaVersionTile({Key? key}) : super(key: key);

  @override
  _HomeFlutterVersionStateTile createState() => _HomeFlutterVersionStateTile();
}

class _HomeFlutterVersionStateTile extends State<HomeJavaVersionTile> {
  final ReceivePort _port = ReceivePort('JAVA_HOME_ISOLATE_PORT');

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
        await logger.file(LogTypeTag.error, 'Java version check timeout');
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
      return const HomeToolErrorTile(toolName: 'Java');
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
                  SvgPicture.asset(Assets.java, height: 20),
                  HSeparators.small(),
                  Expanded(
                    child: Text(
                      'Java - ${_doneLoading ? (_version ?? 'Not installed') : '...'}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const StageTile(),
                  HSeparators.normal(),
                  if (!_doneLoading)
                    const Text('- ')
                  else if (_version == null)
                    SvgPicture.asset(Assets.warn, height: 20)
                  else
                    SvgPicture.asset(Assets.done, height: 20),
                ],
              ),
              VSeparators.normal(),
              HoverMessageWithIconAction(
                message: _doneLoading
                    ? (_version == null
                        ? 'Java is not installed'
                        : 'Java is installed')
                    : '...',
                icon: Icon(
                    _doneLoading
                        ? (_version == null
                            ? Icons.warning
                            : Icons.check_rounded)
                        : Icons.lock_clock,
                    color: _doneLoading
                        ? (_version == null ? AppTheme.errorColor : kGreenColor)
                        : kYellowColor,
                    size: 15),
              ),
              VSeparators.normal(),
              if (_doneLoading && _version == null) ...<Widget>[
                HoverMessageWithIconAction(
                  message: 'Install Java',
                  icon: const Icon(Icons.download_rounded,
                      color: kGreenColor, size: 15),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) =>
                          const InstallToolDialog(tool: SetUpTab.installJava),
                    );
                  },
                ),
                VSeparators.normal(),
                RectangleButton(
                  width: double.infinity,
                  child: const Text('Install Java'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) =>
                          const InstallToolDialog(tool: SetUpTab.installJava),
                    );
                  },
                ),
              ] else
                informationWidget(
                  'Java is specifically targeted at Android development. When using some plugins, Java helps avoid common issues with Android plugins for Flutter.',
                  type: InformationType.green,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
