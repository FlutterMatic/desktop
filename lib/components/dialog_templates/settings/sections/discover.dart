// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

// 🌎 Project imports:
import 'package:manager/core/libraries/components.dart';
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/meta/utils/app_theme.dart';

class DiscoverSettingsSection extends StatelessWidget {
  const DiscoverSettingsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return TabViewTabHeadline(
      title: 'Discover',
      content: <Widget>[
        ActionOptions(
          actions: <ActionOptionsObject>[
            ActionOptionsObject(
              'GitHub',
              () => launch('https://github.com/FlutterMatic/desktop'),
              icon: SvgPicture.asset(
                Assets.github,
                height: 14,
                color: Theme.of(context).isDarkTheme ? null : Colors.black,
              ),
            ),
            ActionOptionsObject(
              'Twitter',
              () => launch('https://twitter.com/FlutterMatic'),
              icon: SvgPicture.asset(
                Assets.twitter,
                height: 14,
                color: Theme.of(context).isDarkTheme ? null : Colors.black,
              ),
            ),
            ActionOptionsObject(
              'DartPad',
              () => launch('https://www.dartpad.dev/flutter?null_safety=true'),
              icon: SvgPicture.asset(Assets.dart, height: 14),
            ),
            ActionOptionsObject(
              'Flutter Docs',
              () => launch('https://flutter.dev/docs'),
              icon: SvgPicture.asset(
                Assets.flutter,
                height: 14,
                color: Theme.of(context).isDarkTheme ? null : Colors.black,
              ),
            ),
            ActionOptionsObject(
              'Our Docs',
              () {}, // TODO: Navigate to our documentation.
              icon: SvgPicture.asset(
                Assets.doc,
                height: 14,
                color: Theme.of(context).isDarkTheme ? null : Colors.black,
              ),
            ),
          ],
        ),
        VSeparators.small(),
        RoundContainer(
          width: double.infinity,
          color: customTheme.colorScheme.secondary.withOpacity(0.2),
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
                color: customTheme.colorScheme.secondary.withOpacity(0.2),
                hoverColor: customTheme.hoverColor,
                width: 70,
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => const AboutUsDialog(),
                  );
                },
                child: Text(
                  'About',
                  style: TextStyle(color: customTheme.textTheme.bodyText1!.color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
