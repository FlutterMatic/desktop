import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/dialog_templates/about/about_us.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

class DiscoverSettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return TabViewTabHeadline(
      title: 'Discover',
      content: <Widget>[
        Row(
          children: <Widget>[
            // GitHub
            Expanded(
              child: RectangleButton(
                height: 100,
                onPressed: () => launch(
                    'https://github.com/FlutterMatic/FlutterMatic-desktop'),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: SvgPicture.asset(
                        Assets.github,
                        height: 20,
                        color: context.read<ThemeChangeNotifier>().isDarkTheme
                            ? null
                            : Colors.black,
                      ),
                    ),
                    Text(
                      'GitHub',
                      style: TextStyle(
                          color: customTheme.textTheme.bodyText1!.color),
                    ),
                  ],
                ),
              ),
            ),
            HSeparators.small(),
            // DartPad
            Expanded(
              child: RectangleButton(
                height: 100,
                onPressed: () =>
                    launch('https://www.dartpad.dev/flutter?null_safety=true'),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: SvgPicture.asset(Assets.dart, height: 20),
                    ),
                    Text(
                      'DartPad',
                      style: TextStyle(
                          color: customTheme.textTheme.bodyText1!.color),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        VSeparators.small(),
        Row(
          children: <Widget>[
            // Twitter
            Expanded(
              child: RectangleButton(
                height: 100,
                onPressed: () => launch('https://twitter.com/FlutterMatic'),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: SvgPicture.asset(
                        Assets.twitter,
                        height: 20,
                        color: context.read<ThemeChangeNotifier>().isDarkTheme
                            ? null
                            : Colors.black,
                      ),
                    ),
                    Text(
                      'Twitter',
                      style: TextStyle(
                          color: customTheme.textTheme.bodyText1!.color),
                    ),
                  ],
                ),
              ),
            ),
            HSeparators.small(),
            // Docs
            Expanded(
              child: RectangleButton(
                height: 100,
                onPressed: () => launch('https://flutter.dev/docs'),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: SvgPicture.asset(
                        Assets.doc,
                        height: 20,
                        color: context.read<ThemeChangeNotifier>().isDarkTheme
                            ? null
                            : Colors.black,
                      ),
                    ),
                    Text(
                      'Docs',
                      style: TextStyle(
                          color: customTheme.textTheme.bodyText1!.color),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        VSeparators.small(),
        RoundContainer(
          width: double.infinity,
          color: customTheme.accentColor.withOpacity(0.2),
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
                color: customTheme.accentColor.withOpacity(0.2),
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
                  style:
                      TextStyle(color: customTheme.textTheme.bodyText1!.color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
