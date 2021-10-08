// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:url_launcher/url_launcher.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/widgets.dart';

class GitHubSettingsSection extends StatelessWidget {
  const GitHubSettingsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return TabViewTabHeadline(
      title: 'GitHub',
      content: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: RectangleButton(
                height: 100,
                onPressed: () {
                  Navigator.pop(context);
                  launch(
                      'https://github.com/FlutterMatic/FlutterMatic-desktop/issues/new');
                },
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Icon(Icons.error_outline_rounded,
                          color: customTheme.iconTheme.color, size: 30),
                    ),
                    Text(
                      'Create Issue',
                      style: TextStyle(
                          color: customTheme.textTheme.bodyText1!.color),
                    ),
                  ],
                ),
              ),
            ),
            HSeparators.small(),
            Expanded(
              child: RectangleButton(
                height: 100,
                onPressed: () {
                  Navigator.pop(context);
                  launch(
                      'https://github.com/FlutterMatic/FlutterMatic-desktop/pulls');
                },
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Icon(Icons.precision_manufacturing,
                          size: 30, color: customTheme.iconTheme.color),
                    ),
                    Text(
                      'Pull Request',
                      style: TextStyle(
                          color: customTheme.textTheme.bodyText1!.color),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        VSeparators.normal(),
        const Text('Contributions'),
        VSeparators.small(),
        infoWidget(context,
            'We are open-source! We would love to see you make some pull requests to this tool!'),
      ],
    );
  }
}
