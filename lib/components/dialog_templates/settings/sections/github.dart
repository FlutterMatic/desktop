import 'package:flutter/material.dart';
import 'package:manager/components/widgets/buttons/rectangle_button.dart';
import 'package:manager/components/widgets/ui/info_widget.dart';
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
                  // TODO: Launch the URL to file a new issue.
                  launch('');
                  Navigator.pop(context);
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
            const SizedBox(width: 10),
            Expanded(
              child: RectangleButton(
                height: 100,
                onPressed: () {
                  // TODO: Launch the URL to make a new Pull Request.
                  launch('');
                  Navigator.pop(context);
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
        const SizedBox(height: 15),
        const Text(
          'Contributions',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        infoWidget(context,
            'We are open-source! We would love to see you make some pull requests to this app!'),
      ],
    );
  }
}
