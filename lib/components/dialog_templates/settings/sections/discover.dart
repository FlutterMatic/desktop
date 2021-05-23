import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/about/about_us.dart';
import 'package:flutter_installer/components/widgets/buttons/rectangle_button.dart';
import 'package:flutter_installer/components/widgets/buttons/square_button.dart';
import 'package:flutter_installer/utils/constants.dart';
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
        const SizedBox(height: 15),
        Row(
          children: <Widget>[
            // GitHub
            Expanded(
              child: RectangleButton(
                height: 100,
                onPressed: () => launch(GitHubServices.repUrl),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Icon(Iconsdata.github,
                          size: 30, color: customTheme.iconTheme.color),
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
            const SizedBox(width: 10),
            // DartPad
            Expanded(
              child: RectangleButton(
                height: 100,
                onPressed: () =>
                    launch('https://www.dartpad.dev/flutter?null_safety=true'),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Icon(Iconsdata.dartpad,
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
        const SizedBox(height: 10),
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
                      child: Icon(Iconsdata.twitter,
                          size: 30, color: customTheme.iconTheme.color),
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
            const SizedBox(width: 10),
            // Docs
            Expanded(
              child: RectangleButton(
                height: 100,
                onPressed: () => launch('https://flutter.dev/docs'),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Icon(Iconsdata.docs,
                          size: 30, color: customTheme.iconTheme.color),
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
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            const Expanded(
              child: Text(
                'Learn more about FlutterMatic and the people behind it.',
              ),
            ),
            const SizedBox(width: 15),
            SquareButton(
              icon: Icon(Iconsdata.info,
                  size: 20, color: customTheme.textTheme.bodyText1!.color),
              color: customTheme.buttonColor,
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AboutUsDialog(),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
