import 'package:flutter/material.dart';
import 'package:flutter_installer/components/widgets/info_widget.dart';
import 'package:flutter_installer/components/widgets/rectangle_button.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class GitHubSettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'GitHub',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 15),
        Row(
          children: <Widget>[
            Expanded(
              child: RectangleButton(
                height: 100,
                onPressed: () {
                  launch(GitHubServices.issueUrl);
                  Navigator.pop(context);
                },
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Icon(
                        Iconsdata.gitIssue,
                        size: 30,
                        color: customTheme.iconTheme.color,
                      ),
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
            const SizedBox(width: 10),
            Expanded(
              child: RectangleButton(
                height: 100,
                onPressed: () {
                  launch(GitHubServices.pr);
                  Navigator.pop(context);
                },
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Icon(Iconsdata.gitPR,
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
        const SizedBox(height: 15),
        const Text(
          'Contributions',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        infoWidget(
            'We are open-source! We would love to see you make some pull requests to this app!'),
      ],
    );
  }
}
