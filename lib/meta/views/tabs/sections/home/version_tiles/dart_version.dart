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
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/dialog_templates/other/install_tool.dart';
import 'package:fluttermatic/components/dialog_templates/project/create/dart/new_dart.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/shimmer.dart';
import 'package:fluttermatic/core/models/check_response.model.dart';
import 'package:fluttermatic/core/services/checks/check.services.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';
import 'package:fluttermatic/meta/utils/shared_pref.dart';
import 'package:fluttermatic/meta/utils/time_ago.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/elements/hover_info_tile.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/elements/tool_error.dart';

Future<void> _check(List<dynamic> data) async {
  SendPort _port = data[0];
  String _logPath = data[1];

  ServiceCheckResponse _result =
      await CheckServices.checkDart(Directory(_logPath));

  _port.send(<dynamic>[
    _result.version?.toString(),
    _result.channel,
  ]);
}

class HomeDartVersionTile extends StatefulWidget {
  const HomeDartVersionTile({Key? key}) : super(key: key);

  @override
  _HomeFlutterVersionStateTile createState() => _HomeFlutterVersionStateTile();
}

class _HomeFlutterVersionStateTile extends State<HomeDartVersionTile> {
  final ReceivePort _port = ReceivePort('DART_HOME_ISOLATE_PORT');

  Version? _version;
  String _channel = '...';

  // Utils
  bool _error = false;
  bool _doneLoading = false;
  bool _listening = false;

  Future<void> _load() async {
    while (mounted) {
      // Avoid an isolate if this is on macOS because of some complications.
      if (Platform.isMacOS) {
        ServiceCheckResponse _info = await CheckServices.checkDart();

        setState(() {
          _version = _info.version;
          _channel = _info.channel ?? '...';
          _doneLoading = true;
        });

        // Close the unnecessary ports
        _port.close();
      } else {
        Directory _logPath = await getApplicationSupportDirectory();
        Isolate _i = await Isolate.spawn(
                _check, <dynamic>[_port.sendPort, _logPath.path])
            .timeout(const Duration(minutes: 1), onTimeout: () async {
          await logger.file(LogTypeTag.error, 'Dart version check timeout');
          setState(() => _error = true);

          return Isolate.current;
        });

        if (mounted && !_listening) {
          _port.listen((dynamic data) {
            _i.kill();
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
                _channel = data[1] as String? ?? '...';
              });
            }
          });
        }
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
      return const HomeToolErrorTile(toolName: 'Dart');
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
                  SvgPicture.asset(Assets.dart, height: 20),
                  HSeparators.small(),
                  Expanded(
                    child: Text(
                      'Dart - ${_version ?? '...'}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
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
              IgnorePointer(
                ignoring: _version == null && _doneLoading,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _version == null && _doneLoading ? 0.2 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      HoverMessageWithIconAction(
                        message: _doneLoading
                            ? (_version == null
                                ? 'Dart is not installed on your device'
                                : 'Dart is up to date on channel ${_channel.toLowerCase()}')
                            : '...',
                        icon: Icon(
                            _doneLoading
                                ? (_version == null
                                    ? Icons.error
                                    : Icons.check_rounded)
                                : Icons.lock_clock,
                            color: _doneLoading
                                ? (_version == null
                                    ? AppTheme.errorColor
                                    : kGreenColor)
                                : kYellowColor,
                            size: 15),
                      ),
                      VSeparators.normal(),
                      HoverMessageWithIconAction(
                        message: SharedPref()
                                .pref
                                .containsKey(SPConst.lastDartUpdateCheck)
                            ? 'Checked for new updates ${getTimeAgo(DateTime.parse(SharedPref().pref.getString(SPConst.lastDartUpdateCheck) ?? '...'))}'
                            : 'Never checked for new updates before',
                        icon: const Icon(Icons.refresh_rounded,
                            color: kGreenColor, size: 15),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const _UpdatingDartDialog(),
                          );
                        },
                      ),
                      VSeparators.normal(),
                      HoverMessageWithIconAction(
                        message: SharedPref()
                                .pref
                                .containsKey(SPConst.lastDartUpdate)
                            ? 'Last updated ${getTimeAgo(DateTime.parse(SharedPref().pref.getString(SPConst.lastDartUpdate) ?? '...'))}'
                            : 'Never updated before',
                        icon: const Icon(Icons.check_rounded,
                            color: kGreenColor, size: 15),
                      ),
                    ],
                  ),
                ),
              ),
              VSeparators.normal(),
              if (_version != null || !_doneLoading)
                Row(
                  children: <Widget>[
                    Expanded(
                      child: RectangleButton(
                        child: const Text('Check Updates'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const _UpdatingDartDialog(),
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
                            builder: (_) => const NewDartProjectDialog(),
                          );
                        },
                      ),
                    ),
                  ],
                )
              else
                RectangleButton(
                  width: double.infinity,
                  child: const Text('Install Dart'),
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

class _UpdatingDartDialog extends StatelessWidget {
  const _UpdatingDartDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          const DialogHeader(title: 'Updating Dart'),
          infoWidget(context,
              'Dart is preinstalled with Flutter. This means that whenever there is a new Flutter version, Dart will be updated automatically by Flutter. This ensures that the Flutter SDK supports the latest Dart version.'),
          VSeparators.normal(),
          RectangleButton(
            width: double.infinity,
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
