// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/action_options.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/tab_view.dart';

class UpdatesSettingsSection extends StatelessWidget {
  const UpdatesSettingsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabViewTabHeadline(
      title: 'FlutterMatic Programs',
      content: <Widget>[
        informationWidget(
            'Version: $appVersion (${appBuild.substring(0, 1).toUpperCase() + appBuild.substring(1).toLowerCase()}) - Latest',
            type: InformationType.green),
        if (appBuild.toLowerCase() != 'stable')
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: informationWidget(
                'If you are interested in joining our preview programs (switch to Beta or Alpha), you can do so here. We recommend that you stay in the Stable channel for the best experience.'),
          ),
        VSeparators.small(),
        ActionOptions(
          actionButtonBuilder: (_, ActionOptionsObject action) {
            switch (action.title) {
              case 'Stable':
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Tooltip(
                    padding: const EdgeInsets.all(5),
                    message: '''
This is the stage that we recommend you stay in for the best experience. 
We will be releasing stable updates only to this channel.''',
                    child: SvgPicture.asset(Assets.done, height: 15),
                  ),
                );
              case 'Beta':
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Tooltip(
                    padding: const EdgeInsets.all(5),
                    message: '''
This is more stable than Alpha, but less stable than the normal release. 
Join if you are interested in seeing upcoming features earlier.''',
                    child: SvgPicture.asset(Assets.warn, height: 15),
                  ),
                );
              case 'Alpha':
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Tooltip(
                    padding: const EdgeInsets.all(5),
                    message: '''
This preview stage is not recommended unless you are ok with risky unstable 
builds.''',
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
