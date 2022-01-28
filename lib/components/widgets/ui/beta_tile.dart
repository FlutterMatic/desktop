import 'package:flutter/material.dart';
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/warning_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class BetaTile extends StatelessWidget {
  const BetaTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          showDialog(context: context, builder: (_) => const _BetaInfoDialog()),
      child: const Tooltip(
        message:
            'This feature is beta and may not work properly. Click to learn more.',
        child: RoundContainer(
          borderColor: kGreenColor,
          color: Colors.transparent,
          padding: EdgeInsets.all(6),
          child: Text(
            'Beta',
            style: TextStyle(color: kGreenColor, fontSize: 12),
          ),
        ),
      ),
    );
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
            'Features that have the beta tag are features that are not ready for general use yet. They may not work as expected, and may be removed or changed at any time. We recommend you check them out and let us know if you have experience any issues.',
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
