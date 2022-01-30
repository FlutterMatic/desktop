// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';

class WorkflowStartUp extends StatelessWidget {
  final Function() onRun;
  final WorkflowTemplate template;

  const WorkflowStartUp({
    Key? key,
    required this.onRun,
    required this.template,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RoundContainer(
          width: 500,
          color: Colors.blueGrey.withOpacity(0.2),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(template.name),
                    VSeparators.xSmall(),
                    Text(template.description,
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              HSeparators.normal(),
              SvgPicture.asset(Assets.done, color: kGreenColor, height: 20),
            ],
          ),
        ),
        VSeparators.normal(),
        SizedBox(
          width: 500,
          child: informationWidget(
            'You won\'t be able to use FlutterMatic until the workflow is completed.',
            type: InformationType.info,
          ),
        ),
        VSeparators.normal(),
        RectangleButton(
          child: const Text('Start'),
          onPressed: onRun,
        ),
      ],
    );
  }
}
