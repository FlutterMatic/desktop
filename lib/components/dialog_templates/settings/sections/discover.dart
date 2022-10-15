// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/about/about_us.dart';
import 'package:fluttermatic/components/dialog_templates/fun/type_test.dart';
import 'package:fluttermatic/components/widgets/buttons/action_options.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/tab_view.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/theme.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/meta/views/dialogs/documentation.dart';

class DiscoverSettingsSection extends StatelessWidget {
  const DiscoverSettingsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        ThemeState themeState = ref.watch(themeStateController);

        return TabViewTabHeadline(
          title: 'Discover',
          content: <Widget>[
            ActionOptions(
              actions: <ActionOptionsObject>[
                ActionOptionsObject(
                  'Typing speed',
                  () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (_) => const TypeTestChallengeDialog(),
                    );
                  },
                  icon: const Icon(Icons.keyboard_rounded, size: 15),
                ),
                ActionOptionsObject(
                  'Twitter',
                  () =>
                      launchUrl(Uri.parse('https://twitter.com/FlutterMatic')),
                  icon: SvgPicture.asset(Assets.twitter,
                      height: 14, color: Colors.blue),
                ),
                ActionOptionsObject(
                  'DartPad',
                  () => launchUrl(Uri.parse(
                      'https://www.dartpad.dev/flutter?null_safety=true')),
                  icon: SvgPicture.asset(Assets.dart, height: 14),
                ),
                ActionOptionsObject(
                  'Flutter Docs',
                  () => launchUrl(Uri.parse('https://flutter.dev/docs')),
                  icon: SvgPicture.asset(Assets.flutter, height: 14),
                ),
                ActionOptionsObject(
                  'Our Docs',
                  () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (_) => const DocumentationDialog(),
                    );
                  },
                  icon: SvgPicture.asset(
                    Assets.doc,
                    color: themeState.darkTheme ? null : Colors.black,
                    height: 14,
                  ),
                ),
              ],
            ),
            VSeparators.small(),
            RoundContainer(
              width: double.infinity,
              child: Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'Learn more about this open-source project.',
                      style: TextStyle(fontSize: 13.5),
                    ),
                  ),
                  HSeparators.small(),
                  RectangleButton(
                    width: 70,
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (_) => const AboutUsDialog(),
                      );
                    },
                    child: const Text('About'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
