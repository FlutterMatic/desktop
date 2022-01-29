// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:url_launcher/url_launcher.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';

class StageTile extends StatelessWidget {
  final StageType stageType;

  const StageTile({Key? key, this.stageType = StageType.beta}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: stageType == StageType.prerelease
          ? null
          : () {
              switch (stageType) {
                case StageType.beta:
                  showDialog(
                    context: context,
                    builder: (_) => const _BetaInfoDialog(),
                  );
                  break;
                case StageType.alpha:
                  showDialog(
                    context: context,
                    builder: (_) => const _AlphaInfoDialog(),
                  );
                  break;
                case StageType.prerelease:
                  break;
              }
            },
      child: Tooltip(
        message: _message(stageType),
        child: RoundContainer(
          borderColor: kGreenColor,
          color: Colors.transparent,
          padding: const EdgeInsets.all(6),
          child: Text(
            _name(stageType),
            style: const TextStyle(color: kGreenColor, fontSize: 12),
          ),
        ),
      ),
    );
  }
}

enum StageType { beta, alpha, prerelease }

String _name(StageType type) {
  switch (type) {
    case StageType.beta:
      return 'Beta';
    case StageType.alpha:
      return 'Alpha';
    case StageType.prerelease:
      return 'Pre-release';
  }
}

String _message(StageType type) {
  switch (type) {
    case StageType.beta:
      return 'This feature is in beta and may not work properly. Click to learn more.';
    case StageType.alpha:
      return 'This feature is in alpha and can have many errors or bugs. Click to learn more.';
    case StageType.prerelease:
      return 'This feature is available but not ready for general use.';
  }
}

class _BetaInfoDialog extends StatelessWidget {
  const _BetaInfoDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          const DialogHeader(title: 'Beta Features'),
          informationWidget(
            'Features that have the beta tag are features that are ready for general use, however, they may not work as expected. We recommend you check them out and let us know if you have experience any issues.',
            type: InformationType.warning,
          ),
          VSeparators.normal(),
          Row(
            children: <Widget>[
              Expanded(
                child: RectangleButton(
                  child: const Text('Report Issue'),
                  onPressed: () {
                    launch(
                        'https://github.com/fluttermatic/desktop/issues/new/choose');
                    Navigator.pop(context);
                  },
                ),
              ),
              HSeparators.normal(),
              Expanded(
                child: RectangleButton(
                  child: const Text('Close'),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _AlphaInfoDialog extends StatelessWidget {
  const _AlphaInfoDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          const DialogHeader(title: 'Alpha Features'),
          informationWidget(
            'Features that have the alpha tag are features that are not ready for general use yet. They may not work as expected, and may be removed or changed at any time. We recommend you check them out and let us know if you have experience any issues.',
            type: InformationType.warning,
          ),
          VSeparators.normal(),
          Row(
            children: <Widget>[
              Expanded(
                child: RectangleButton(
                  child: const Text('Report Issue'),
                  onPressed: () {
                    launch(
                        'https://github.com/fluttermatic/desktop/issues/new/choose');
                    Navigator.pop(context);
                  },
                ),
              ),
              HSeparators.normal(),
              Expanded(
                child: RectangleButton(
                  child: const Text('Close'),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
