// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/enum.dart';
import 'package:fluttermatic/bin/check_services.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/dialog_templates/other/install_tool.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/shimmer.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/meta/utils/general/app_theme.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/elements/hover_info_tile.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/elements/tool_error.dart';

class HomeJavaVersionTile extends ConsumerWidget {
  const HomeJavaVersionTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CheckServicesState state = ref.watch(checkServicesStateNotifier);
    CheckServicesNotifier notifier =
        ref.watch(checkServicesStateNotifier.notifier);

    if (state.javaError.isNotEmpty) {
      return const HomeToolErrorTile(toolName: 'Java');
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
                  SvgPicture.asset(Assets.java, height: 20),
                  HSeparators.small(),
                  Expanded(
                    child: Text(
                      'Java - ${state.loading ? (notifier.java?.version ?? 'Not installed') : '...'}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  HSeparators.normal(),
                  if (state.loading)
                    const Text('- ')
                  else if (notifier.java?.version == null)
                    SvgPicture.asset(Assets.warn, height: 20)
                  else
                    SvgPicture.asset(Assets.done, height: 20),
                ],
              ),
              VSeparators.normal(),
              IgnorePointer(
                ignoring: notifier.java?.version == null && state.loading,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: notifier.java?.version == null && state.loading ? 0.2 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      HoverMessageWithIconAction(
                        message: state.loading
                            ? (notifier.java?.version == null
                                ? 'Java is not installed'
                                : 'Java is installed')
                            : '...',
                        icon: Icon(
                          state.loading
                              ? (notifier.java?.version == null
                                  ? Icons.warning
                                  : Icons.check_rounded)
                              : Icons.lock_clock,
                          color: state.loading
                              ? (notifier.java?.version == null
                                  ? AppTheme.errorColor
                                  : kGreenColor)
                              : kYellowColor,
                          size: 15,
                        ),
                      ),
                      VSeparators.normal(),
                      HoverMessageWithIconAction(
                        message: state.loading
                            ? (notifier.java?.version == null
                                ? 'Install Java for Android development'
                                : 'Java for Android development')
                            : '...',
                        icon: Icon(
                            state.loading
                                ? (notifier.java?.version == null
                                    ? Icons.download_rounded
                                    : Icons.check_rounded)
                                : Icons.lock_clock,
                            color: state.loading
                                ? (notifier.java?.version == null
                                    ? AppTheme.errorColor
                                    : kGreenColor)
                                : kYellowColor,
                            size: 15),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const InstallToolDialog(
                              tool: SetUpTab.installJava,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              VSeparators.normal(),
              if (state.loading && notifier.java?.version == null)
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
