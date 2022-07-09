// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pub_semver/src/version.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/enum.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/dialog_templates/other/install_tool.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/shimmer.dart';
import 'package:fluttermatic/meta/utils/general/app_theme.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/elements/hover_info_tile.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/elements/tool_error.dart';

class HomeJavaVersionTile extends StatefulWidget {
  const HomeJavaVersionTile({Key? key}) : super(key: key);

  @override
  _HomeFlutterVersionStateTile createState() => _HomeFlutterVersionStateTile();
}

class _HomeFlutterVersionStateTile extends State<HomeJavaVersionTile> {
  Version? _version;

  // Utils
  bool _error = false;
  bool _doneLoading = false;
  bool _listening = false;

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
