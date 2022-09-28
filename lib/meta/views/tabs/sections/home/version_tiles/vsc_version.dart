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

class HomeVSCVersionTile extends ConsumerWidget {
  const HomeVSCVersionTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CheckServicesState state = ref.watch(checkServicesStateNotifier);
    CheckServicesNotifier notifier =
        ref.watch(checkServicesStateNotifier.notifier);

    if (state.codeError.isNotEmpty) {
      return const HomeToolErrorTile(toolName: 'VS Code');
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
                  SvgPicture.asset(Assets.vscode, height: 20),
                  HSeparators.small(),
                  Expanded(
                    child: Text(
                      'VS Code - ${notifier.vsCode?.version ?? '...'}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const StageTile(stageType: StageType.beta),
                  HSeparators.normal(),
                  if (state.loading)
                    const Text('- ')
                  else if (notifier.vsCode?.version == null)
                    SvgPicture.asset(Assets.error, height: 20)
                  else
                    SvgPicture.asset(Assets.done, height: 20),
                ],
              ),
              VSeparators.normal(),
              IgnorePointer(
                ignoring: notifier.vsCode?.version == null && state.loading,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: notifier.vsCode?.version == null && state.loading ? 0.2 : 1,
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
              if (notifier.vsCode?.version != null || !state.loading)
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
