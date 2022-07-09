// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pub_semver/src/version.dart';
import 'package:url_launcher/url_launcher.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/enum.dart';
import 'package:fluttermatic/app/shared_pref.dart';
import 'package:fluttermatic/components/dialog_templates/other/install_tool.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/shimmer.dart';
import 'package:fluttermatic/components/widgets/ui/stage_tile.dart';
import 'package:fluttermatic/meta/utils/general/shared_pref.dart';
import 'package:fluttermatic/meta/utils/general/time_ago.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/elements/hover_info_tile.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/elements/tool_error.dart';

class HomeVSCVersionTile extends StatefulWidget {
  const HomeVSCVersionTile({Key? key}) : super(key: key);

  @override
  _HomeVSCVersionStateTile createState() => _HomeVSCVersionStateTile();
}

class _HomeVSCVersionStateTile extends State<HomeVSCVersionTile> {
  Version? _version;

  // Utils
  bool _error = false;
  bool _doneLoading = false;
  bool _listening = false;

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return const HomeToolErrorTile(toolName: 'VS Code');
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
                  SvgPicture.asset(Assets.vscode, height: 20),
                  HSeparators.small(),
                  Expanded(
                    child: Text(
                      'VS Code - ${_version ?? '...'}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const StageTile(stageType: StageType.beta),
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
                                .containsKey(SPConst.lastVSCodeUpdateCheck)
                            ? 'Checked for new updates ${getTimeAgo(DateTime.parse(SharedPref().pref.getString(SPConst.lastVSCodeUpdateCheck) ?? '...'))}'
                            : 'Never checked for new updates before',
                        icon: const Icon(Icons.refresh_rounded,
                            color: kGreenColor, size: 15),
                        onPressed: () {
                          SharedPref().pref.setString(
                              SPConst.lastVSCodeUpdateCheck,
                              DateTime.now().toIso8601String());
                          launchUrl(
                              Uri.parse('https://code.visualstudio.com/'));
                        },
                      ),
                      VSeparators.normal(),
                      const HoverMessageWithIconAction(
                        message: 'Make sure to always keep your IDE up to date',
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
                    SharedPref().pref.setString(SPConst.lastVSCodeUpdateCheck,
                        DateTime.now().toIso8601String());
                    launchUrl(Uri.parse('https://code.visualstudio.com/'));
                  },
                  child: const Text('Check Updates'),
                )
              else
                RectangleButton(
                  width: double.infinity,
                  child: const Text('Install VS Code'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) =>
                          const InstallToolDialog(tool: SetUpTab.installEditor),
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
