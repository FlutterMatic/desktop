import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/dialog_templates/about/about_us.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class DiscoverSettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Discover',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        VSeparators.normal(),
        Row(
          children: <Widget>[
            // GitHub
            Expanded(
              child: RectangleButton(
                height: 100,
                // TODO: Launch the GitHub repository for the project.
                onPressed: () => launch(''),
                child: Column(
                  children: <Widget>[
                    Expanded(child: SvgPicture.asset(Assets.github)),
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
                      child: Icon(Icons.note,
                          size: 30, color: customTheme.iconTheme.color),
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
                    Expanded(child: SvgPicture.asset(Assets.twitter)),
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
                      child: SvgPicture.asset(Assets.docs),
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
        Row(
          children: <Widget>[
            const Expanded(
              child: Text(
                'Learn more about FlutterMatic and the people behind it.',
              ),
            ),
            HSeparators.normal(),
            SquareButton(
              icon: Icon(Icons.info,
                  size: 20, color: customTheme.textTheme.bodyText1!.color),
              color: customTheme.buttonColor,
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => const AboutUsDialog(),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
