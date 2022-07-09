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

class HomeStudioVersionTile extends StatefulWidget {
  const HomeStudioVersionTile({Key? key}) : super(key: key);

  @override
  _HomeStudioVersionStateTile createState() => _HomeStudioVersionStateTile();
}

class _HomeStudioVersionStateTile extends State<HomeStudioVersionTile> {
  Version? _version;

  // Utils
  bool _error = false;
  bool _doneLoading = false;
  bool _listening = false;

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return const HomeToolErrorTile(toolName: 'Studio');
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
                  SvgPicture.asset(Assets.studio, height: 20),
                  HSeparators.small(),
                  Expanded(
                    child: Text(
                      'Studio - ${_version ?? '...'}',
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
                        message: SharedPref().pref.containsKey(
                                SPConst.lastAndroidStudioUpdateCheck)
                            ? 'Checked for new updates ${getTimeAgo(DateTime.parse(SharedPref().pref.getString(SPConst.lastAndroidStudioUpdateCheck) ?? '...'))}'
                            : 'Never checked for new updates before',
                        icon: const Icon(Icons.refresh_rounded,
                            color: kGreenColor, size: 15),
                        onPressed: () {
                          SharedPref().pref.setString(
                              SPConst.lastAndroidStudioUpdateCheck,
                              DateTime.now().toIso8601String());
                          launchUrl(Uri.parse(
                              'https://developer.android.com/studio'));
                        },
                      ),
                      VSeparators.normal(),
                      const HoverMessageWithIconAction(
                        message:
                            'Make sure to always keep Android Studio up to date',
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
                    SharedPref().pref.setString(
                        SPConst.lastAndroidStudioUpdateCheck,
                        DateTime.now().toIso8601String());
                    launchUrl(
                        Uri.parse('https://developer.android.com/studio'));
                  },
                  child: const Text('Check Updates'),
                )
              else
                RectangleButton(
                  width: double.infinity,
                  child: const Text('Install Studio'),
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
