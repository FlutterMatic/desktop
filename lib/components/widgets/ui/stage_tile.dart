// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:url_launcher/url_launcher.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';

class StageTile extends StatefulWidget {
  final StageType stageType;

  const StageTile({Key? key, this.stageType = StageType.beta})
      : super(key: key);

  @override
  State<StageTile> createState() => _StageTileState();
}

class _StageTileState extends State<StageTile> {
  bool _isVisible = false;

  @override
  void initState() {
    Future<void>.delayed(const Duration(milliseconds: 100)).then((_) {
      if (mounted) {
        setState(() => _isVisible = true);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isVisible ? 0.6 : 0,
      duration: const Duration(milliseconds: 300),
      child: InkWell(
        onTap: widget.stageType == StageType.prerelease
            ? null
            : () {
                switch (widget.stageType) {
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
          message: _message(widget.stageType),
          child: RoundContainer(
            borderColor: kGreenColor,
            color: Colors.transparent,
            padding: const EdgeInsets.all(6),
            child: Text(
              _name(widget.stageType),
              style: const TextStyle(color: kGreenColor, fontSize: 12),
            ),
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
      return 'This feature is in alpha and can have errors or bugs. Click to learn more.';
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
          infoWidget(
            context,
            'Features that have the beta tag are features that are ready for general use, however, they may not work as expected. We recommend you check them out and let us know if you have experience any issues.',
          ),
          VSeparators.normal(),
          Row(
            children: <Widget>[
              Expanded(
                child: RectangleButton(
                  child: const Text('Report Issue'),
                  onPressed: () {
                    launchUrl(Uri.parse(
                        'https://github.com/fluttermatic/desktop/issues/new/choose'));
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
          infoWidget(
            context,
            'Features that have the alpha tag are features that are not ready for general use yet. They may not work as expected, and may be removed or changed at any time. We recommend you check them out and let us know if you have experience any issues.',
          ),
          VSeparators.normal(),
          Row(
            children: <Widget>[
              Expanded(
                child: RectangleButton(
                  child: const Text('Report Issue'),
                  onPressed: () {
                    launchUrl(Uri.parse(
                        'https://github.com/fluttermatic/desktop/issues/new/choose'));
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
