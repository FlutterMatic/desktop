// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/enum.dart';
import 'package:fluttermatic/app/shared_pref.dart';
import 'package:fluttermatic/bin/check_services.dart';
import 'package:fluttermatic/components/dialog_templates/flutter/switch.dart';
import 'package:fluttermatic/components/dialog_templates/flutter/upgrade.dart';
import 'package:fluttermatic/components/dialog_templates/other/install_tool.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/shimmer.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/meta/utils/general/app_theme.dart';
import 'package:fluttermatic/meta/utils/general/shared_pref.dart';
import 'package:fluttermatic/meta/utils/general/time_ago.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/elements/hover_info_tile.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/elements/tool_error.dart';

class HomeFlutterVersionTile extends ConsumerWidget {
  const HomeFlutterVersionTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CheckServicesState state = ref.watch(checkServicesStateNotifier);
    CheckServicesNotifier notifier =
        ref.watch(checkServicesStateNotifier.notifier);

    if (state.flutterError.isNotEmpty) {
      return const HomeToolErrorTile(toolName: 'Flutter');
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
                  SvgPicture.asset(Assets.flutter, height: 20),
                  HSeparators.small(),
                  Expanded(
                    child: Text(
                      'Flutter - ${notifier.flutter?.version ?? '...'}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  HSeparators.normal(),
                  if (state.loading)
                    const Text('- ')
                  else if (notifier.flutter?.version == null)
                    SvgPicture.asset(Assets.error, height: 20)
                  else
                    SvgPicture.asset(Assets.done, height: 20),
                ],
              ),
              VSeparators.normal(),
              IgnorePointer(
                ignoring: notifier.flutter?.version == null && state.loading,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: notifier.flutter?.version == null && state.loading
                      ? 0.2
                      : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      HoverMessageWithIconAction(
                        message: !state.loading
                            ? (notifier.flutter?.version == null
                                ? 'Flutter is not installed on your device'
                                : 'Flutter is up to date on channel ${notifier.flutter?.channel?.toLowerCase()}')
                            : '...',
                        icon: Icon(
                            !state.loading
                                ? (notifier.flutter?.version == null
                                    ? Icons.error
                                    : Icons.check_rounded)
                                : Icons.lock_clock,
                            color: !state.loading
                                ? (notifier.flutter?.version == null
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
              if (notifier.flutter?.version != null && !state.loading)
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
