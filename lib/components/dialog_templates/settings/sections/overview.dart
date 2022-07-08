// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/shared_pref.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/inputs/check_box_element.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/tab_view.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/theme.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/meta/utils/general/shared_pref.dart';

class OverviewSettingsSection extends StatefulWidget {
  const OverviewSettingsSection({Key? key}) : super(key: key);

  @override
  _OverviewSettingsSectionState createState() =>
      _OverviewSettingsSectionState();
}

class _OverviewSettingsSectionState extends State<OverviewSettingsSection> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        ThemeState themeState = ref.watch(themeStateController);

        var themeNotifier = ref.watch(themeStateController.notifier);

        return TabViewTabHeadline(
          title: 'Overview',
          allowContentScroll: false,
          content: <Widget>[
            RoundContainer(
              child: CheckBoxElement(
                onChanged: (bool? value) async {
                  await SharedPref()
                      .pref
                      .setBool(SPConst.homeShowGuide, value ?? false);
                  setState(() {});
                },
                value: SharedPref().pref.getBool(SPConst.homeShowGuide) ?? true,
                text: 'Show home page setup guide',
              ),
            ),
            VSeparators.normal(),
            const Text('Theme'),
            VSeparators.small(),
            _themeTiles(
              context,
              selected: !themeState.isDarkTheme && !themeState.isSystemTheme,
              title: 'Light Mode',
              description: 'Get a bright and shining desktop',
              onPressed: () {
                if (themeState.isDarkTheme) {
                  themeNotifier.updateTheme(
                      Theme.of(context).brightness == Brightness.light);
                }
              },
            ),
            VSeparators.small(),
            _themeTiles(
              context,
              selected: themeState.isDarkTheme && !themeState.isSystemTheme,
              title: 'Dark Mode',
              description: 'For dark and nighty appearance',
              onPressed: () {
                if (!themeState.isDarkTheme) {
                  themeNotifier.updateTheme(
                      Theme.of(context).brightness == Brightness.light);
                }
              },
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: SelectableText(
                '$appVersion - $appBuild',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget _themeTiles(
  BuildContext context, {
  required bool selected,
  required String title,
  required String description,
  required Function() onPressed,
}) {
  return RectangleButton(
    height: 65,
    onPressed: onPressed,
    width: double.infinity,
    hoverColor: Colors.transparent,
    focusColor: Colors.transparent,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    padding: const EdgeInsets.all(10),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title),
                VSeparators.xSmall(),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          if (selected) const Icon(Icons.check_rounded, color: kGreenColor),
        ],
      ),
    ),
  );
}
