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
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/dialog_templates/other/install_tool.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/shimmer.dart';
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
  return;
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
      // Avoid an isolate if this is on macOS because of some complications.
      if (Platform.isMacOS) {
        ServiceCheckResponse _info = await CheckServices.checkJava();

        setState(() {
          _version = _info.version;
          _doneLoading = true;
        });

        // Close the unnecessary ports
        _port.close();
      } else {
        Directory _logPath = await getApplicationSupportDirectory();
        Isolate _i = await Isolate.spawn(
                _check, <dynamic>[_port.sendPort, _logPath.path])
            .timeout(const Duration(minutes: 1), onTimeout: () async {
          await logger.file(LogTypeTag.error, 'Java version check timeout');
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
                              ? (_version == null
                                  ? AppTheme.errorColor
                                  : kGreenColor)
                              : kYellowColor,
                          size: 15,
                        ),
                      ),
                      VSeparators.normal(),
                      HoverMessageWithIconAction(
                        message: _doneLoading
                            ? (_version == null
                                ? 'Install Java for Android development'
                                : 'Java for Android development')
                            : '...',
                        icon: Icon(
                            _doneLoading
                                ? (_version == null
                                    ? Icons.download_rounded
                                    : Icons.check_rounded)
                                : Icons.lock_clock,
                            color: _doneLoading
                                ? (_version == null
                                    ? AppTheme.errorColor
                                    : kGreenColor)
                                : kYellowColor,
                            size: 15),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const InstallToolDialog(
                                tool: SetUpTab.installJava),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              VSeparators.normal(),
              if (_doneLoading && _version == null)
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
                )
              else
                RectangleButton(
                  width: double.infinity,
                  child: const Text('Learn more'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const _JavaAndroidDevelopment(),
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

class _JavaAndroidDevelopment extends StatelessWidget {
  const _JavaAndroidDevelopment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          const DialogHeader(title: 'Java'),
          informationWidget(
            'Java is specifically targeted at Android development. When using some plugins, Java helps avoid common issues with Android plugins for Flutter.',
            type: InformationType.green,
          ),
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
