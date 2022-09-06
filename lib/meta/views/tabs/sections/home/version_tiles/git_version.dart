// 🎯 Dart imports:
import 'dart:io';
import 'dart:isolate';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pub_semver/src/version.dart';
import 'package:url_launcher/url_launcher.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/enum.dart';
import 'package:fluttermatic/app/shared_pref.dart';
import 'package:fluttermatic/bin/check_services.dart';
import 'package:fluttermatic/components/dialog_templates/other/install_tool.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/shimmer.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/general/shared_pref.dart';
import 'package:fluttermatic/meta/utils/general/time_ago.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/elements/hover_info_tile.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/elements/tool_error.dart';

Future<void> _check(List<dynamic> data) async {
  SendPort port = data[0];
  String logPath = data[1];

  ServiceCheckResponse result =
      await CheckServices.checkGit(Directory(logPath));

  port.send(<dynamic>[
    result.version?.toString(),
  ]);
  return;
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
      // Avoid an isolate if this is on macOS because of some complications.
      if (Platform.isMacOS) {
        ServiceCheckResponse info = await CheckServices.checkGit();

        setState(() {
          _version = info.version;
          _doneLoading = true;
        });

        // Close the unnecessary ports
        _port.close();
      } else {
        Directory logPath = await getApplicationSupportDirectory();
        Isolate i = await Isolate.spawn(
                _check, <dynamic>[_port.sendPort, logPath.path])
            .timeout(const Duration(minutes: 1), onTimeout: () async {
          await logger.file(LogTypeTag.error, 'Git version check timeout');
          setState(() => _error = true);

          return Isolate.current;
        });

        if (mounted && !_listening) {
          _port.listen((dynamic data) {
            i.kill();
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

  String get _updateUrl {
    String base = 'https://git-scm.com/download/';
    String platform = '';

    if (Platform.isWindows) {
      platform = 'win';
    } else if (Platform.isMacOS) {
      platform = 'mac';
    } else if (Platform.isLinux) {
      platform = 'linux';
    }

    return '$base$platform';
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
                        message: SharedPref()
                                .pref
                                .containsKey(SPConst.lastGitUpdateCheck)
                            ? 'Checked for new updates ${getTimeAgo(DateTime.parse(SharedPref().pref.getString(SPConst.lastGitUpdateCheck) ?? '...'))}'
                            : 'Never checked for new updates before',
                        icon: const Icon(Icons.refresh_rounded,
                            color: kGreenColor, size: 15),
                        onPressed: () {
                          SharedPref().pref.setString(
                              SPConst.lastGitUpdateCheck,
                              DateTime.now().toIso8601String());
                          launchUrl(Uri.parse(_updateUrl));
                        },
                      ),
                      VSeparators.normal(),
                      const HoverMessageWithIconAction(
                        message: 'Make sure to always keep Git up to date',
                        icon: Icon(Icons.check_rounded,
                            color: kGreenColor, size: 15),
                      ),
                    ],
                  ),
                ),
              ),
              VSeparators.normal(),
              if (_version != null || !_doneLoading)
                RectangleButton(
                  width: double.infinity,
                  onPressed: () {
                    SharedPref().pref.setString(SPConst.lastGitUpdateCheck,
                        DateTime.now().toIso8601String());
                    launchUrl(Uri.parse(_updateUrl));
                  },
                  child: const Text('Check Updates'),
                )
              else
                RectangleButton(
                  width: double.infinity,
                  child: const Text('Install Git'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const InstallToolDialog(
                        tool: SetUpTab.installGit,
                      ),
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
