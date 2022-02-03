// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/dialog_templates/about/about_us.dart';
import 'package:fluttermatic/components/widgets/buttons/action_options.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/tab_view.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';
import 'package:fluttermatic/meta/views/dialogs/documentation.dart';

class DiscoverSettingsSection extends StatelessWidget {
  const DiscoverSettingsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabViewTabHeadline(
      title: 'Discover',
      content: <Widget>[
        ActionOptions(
          actions: <ActionOptionsObject>[
            ActionOptionsObject(
              'GitHub',
              () => launch('https://github.com/FlutterMatic/desktop'),
              icon: SvgPicture.asset(Assets.github,
                  color: Theme.of(context).isDarkTheme ? null : Colors.black,
                  height: 14),
            ),
            ActionOptionsObject(
              'Twitter',
              () => launch('https://twitter.com/FlutterMatic'),
              icon: SvgPicture.asset(Assets.twitter,
                  height: 14, color: Colors.blue),
            ),
            ActionOptionsObject(
              'DartPad',
              () => launch('https://www.dartpad.dev/flutter?null_safety=true'),
              icon: SvgPicture.asset(Assets.dart, height: 14),
            ),
            ActionOptionsObject(
              'Flutter Docs',
              () => launch('https://flutter.dev/docs'),
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
              icon: SvgPicture.asset(Assets.doc,
                  color: Theme.of(context).isDarkTheme ? null : Colors.black,
                  height: 14),
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
  }
}
