// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'package:fluttermatic/components/widgets/ui/stage_tile.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/meta/utils/general/shared_pref.dart';
import 'package:fluttermatic/meta/utils/general/time_ago.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/elements/hover_info_tile.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/elements/tool_error.dart';

class HomeStudioVersionTile extends ConsumerWidget {
  const HomeStudioVersionTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CheckServicesState state = ref.watch(checkServicesStateNotifier);
    CheckServicesNotifier notifier =
        ref.watch(checkServicesStateNotifier.notifier);

    if (state.studioError.isNotEmpty) {
      return const HomeToolErrorTile(toolName: 'Studio');
    }

    return RoundContainer(
      child: Shimmer.fromColors(
        enabled: state.loading,
        child: IgnorePointer(
          ignoring: state.loading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  SvgPicture.asset(Assets.studio, height: 20),
                  HSeparators.small(),
                  Expanded(
                    child: Text(
                      'Studio - ${notifier.studio?.version ?? (state.loading ? '...' : 'Not installed')}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const StageTile(stageType: StageType.beta),
                  HSeparators.normal(),
                  if (state.loading)
                    const Text('- ')
                  else if (notifier.studio?.version == null)
                    SvgPicture.asset(Assets.error, height: 20)
                  else
                    SvgPicture.asset(Assets.done, height: 20),
                ],
              ),
              VSeparators.normal(),
              IgnorePointer(
                ignoring: notifier.studio?.version == null && state.loading,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: notifier.studio?.version == null && state.loading
                      ? 0.2
                      : 1,
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
              if (notifier.studio?.version != null && !state.loading)
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
                      builder: (_) => const InstallToolDialog(
                        tool: SetUpTab.installEditor,
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
