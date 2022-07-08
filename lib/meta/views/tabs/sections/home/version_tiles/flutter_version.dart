// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttermatic/app/enum.dart';
import 'package:fluttermatic/app/shared_pref.dart';
import 'package:fluttermatic/components/dialog_templates/flutter/switch.dart';
import 'package:fluttermatic/components/dialog_templates/flutter/upgrade.dart';
import 'package:fluttermatic/meta/utils/general/app_theme.dart';
import 'package:fluttermatic/meta/utils/general/shared_pref.dart';
import 'package:fluttermatic/meta/utils/general/time_ago.dart';
import 'package:pub_semver/src/version.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/other/install_tool.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/shimmer.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/elements/hover_info_tile.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/elements/tool_error.dart';

class HomeFlutterVersionTile extends StatefulWidget {
  const HomeFlutterVersionTile({Key? key}) : super(key: key);

  @override
  _HomeFlutterVersionStateTile createState() => _HomeFlutterVersionStateTile();
}

class _HomeFlutterVersionStateTile extends State<HomeFlutterVersionTile> {
  Version? _version;
  String _channel = '...';

  // Utils
  bool _error = false;
  bool _doneLoading = false;
  bool _listening = false;

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return const HomeToolErrorTile(toolName: 'Flutter');
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
                  SvgPicture.asset(Assets.flutter, height: 20),
                  HSeparators.small(),
                  Expanded(
                    child: Text(
                      'Flutter - ${_version ?? '...'}',
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
                                ? 'Flutter is not installed on your device'
                                : 'Flutter is up to date on channel ${_channel.toLowerCase()}')
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
                                .containsKey(SPConst.lastFlutterUpdateCheck)
                            ? 'Checked for new updates ${getTimeAgo(DateTime.parse(SharedPref().pref.getString(SPConst.lastFlutterUpdateCheck) ?? '...'))}'
                            : 'Never checked for new updates before',
                        icon: const Icon(Icons.refresh_rounded,
                            color: kGreenColor, size: 15),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const UpgradeFlutterDialog(),
                          );
                        },
                      ),
                      VSeparators.normal(),
                      HoverMessageWithIconAction(
                        message: SharedPref()
                                .pref
                                .containsKey(SPConst.lastFlutterUpdate)
                            ? 'Last updated ${getTimeAgo(DateTime.parse(SharedPref().pref.getString(SPConst.lastFlutterUpdate) ?? '...'))}'
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
                            builder: (_) => const UpgradeFlutterDialog(),
                          );
                        },
                      ),
                    ),
                    HSeparators.normal(),
                    Expanded(
                      child: RectangleButton(
                        child: const Text('Change Channel'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const SwitchFlutterChannelDialog(),
                          );
                        },
                      ),
                    ),
                  ],
                )
              else
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
