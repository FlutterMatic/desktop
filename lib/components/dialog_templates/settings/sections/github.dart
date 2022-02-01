// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/dialog_templates/logs/build_logs.dart';
import 'package:fluttermatic/components/widgets/buttons/action_options.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/tab_view.dart';

class GitHubSettingsSection extends StatelessWidget {
  const GitHubSettingsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabViewTabHeadline(
      title: 'GitHub',
      content: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: RectangleButton(
                height: 100,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Icon(Icons.error_outline_rounded,
                          color: Theme.of(context).iconTheme.color, size: 30),
                    ),
                    const Text('Create Issue'),
                  ],
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => DialogTemplate(
                      child: Column(
                        children: <Widget>[
                          const DialogHeader(title: 'Generate Report?'),
                          informationWidget(
                            'If you are reporting an issue, we recommend you generate a report with our built in report generation feature and upload the file it generates directly in the issue. This helps us resolve the issue quicker.',
                            type: InformationType.info,
                          ),
                          VSeparators.normal(),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: RectangleButton(
                                  child: const Text('Skip'),
                                  onPressed: () async {
                                    await launch(
                                        'https://github.com/FlutterMatic/desktop/issues/new');
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              HSeparators.normal(),
                              Expanded(
                                child: RectangleButton(
                                  child: const Text('Generate'),
                                  onPressed: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (_) => const BuildLogsDialog(),
                                    );
                                    await launch(
                                        'https://github.com/FlutterMatic/desktop/issues/new');
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            HSeparators.small(),
            Expanded(
              child: RectangleButton(
                height: 100,
                onPressed: () {
                  Navigator.pop(context);
                  launch('https://github.com/FlutterMatic/desktop/pulls');
                },
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Icon(Icons.precision_manufacturing,
                          size: 30, color: Theme.of(context).iconTheme.color),
                    ),
                    const Text('Pull Request'),
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
        VSeparators.normal(),
        const Text('FlutterMatic Programs'),
        VSeparators.small(),
        informationWidget(
            'If you are interested in joining our preview programs (switch to Beta or Alpha), you can do so here. We recommend that you stay in the Stable channel for the best experience.'),
        VSeparators.normal(),
        RoundContainer(
          child: Row(
            children: <Widget>[
              const Text('Current Build is '),
              Expanded(
                child: Text(appBuild.substring(0, 1).toUpperCase() +
                    appBuild.substring(1).toLowerCase()),
              ),
              HSeparators.normal(),
              const Icon(Icons.check_rounded, color: kGreenColor, size: 15),
            ],
          ),
        ),
        VSeparators.small(),
        ActionOptions(
          actionButtonBuilder: (_, ActionOptionsObject action) {
            switch (action.title) {
              case 'Stable':
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Tooltip(
                    message:
                        'This is the stage that we recommend you stay in for the best experience. We will be releasing stable updates only to this channel.',
                    child: SvgPicture.asset(Assets.done, height: 15),
                  ),
                );
              case 'Beta':
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Tooltip(
                    message:
                        'This is more stable than Alpha, but less stable than the normal release. Join if you are interested in seeing upcoming features earlier.',
                    child: SvgPicture.asset(Assets.warn, height: 15),
                  ),
                );
              case 'Alpha':
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Tooltip(
                    message:
                        'This preview stage is not recommended unless you are ok with risky unstable builds.',
                    child: SvgPicture.asset(Assets.error, height: 15),
                  ),
                );
              default:
                return const SizedBox.shrink();
            }
          },
          actions: <ActionOptionsObject>[
            if (appBuild.substring(0, 1).toUpperCase() +
                    appBuild.substring(1).toLowerCase() !=
                'Stable')
              ActionOptionsObject('Stable', () {}),
            if (appBuild.substring(0, 1).toUpperCase() +
                    appBuild.substring(1).toLowerCase() !=
                'Beta')
              ActionOptionsObject('Beta', () {}),
            if (appBuild.substring(0, 1).toUpperCase() +
                    appBuild.substring(1).toLowerCase() !=
                'Alpha')
              ActionOptionsObject('Alpha', () {}),
          ],
        ),
      ],
    );
  }
}
