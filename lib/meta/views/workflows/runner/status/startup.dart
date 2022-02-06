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
    return SizedBox(
      width: 500,
      child: Column(
        children: <Widget>[
          informationWidget(
            'You won\'t be able to use FlutterMatic until the workflow is completed.',
            type: InformationType.info,
          ),
          VSeparators.normal(),
          RoundContainer(
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
          RoundContainer(
            width: double.infinity,
            child: Row(
              children: <Widget>[
                RoundContainer(
                  radius: 50,
                  width: 40,
                  height: 40,
                  padding: EdgeInsets.zero,
                  child: Center(
                      child: Text(template.workflowActions.length.toString())),
                ),
                HSeparators.xSmall(),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: template.workflowActions.map((String e) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: RoundContainer(
                              child: Text(e),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          VSeparators.normal(),
          Row(
            children: <Widget>[
              const Icon(Icons.lock_rounded, size: 15),
              HSeparators.xSmall(),
              const Expanded(
                child: Text(
                  'This workflow runs locally on your system. Nothing will be sent to any external resources by us, unless required by the workflow action.',
                  style: TextStyle(fontSize: 10),
                ),
              ),
              HSeparators.normal(),
              RectangleButton(
                width: 100,
                child: const Text('Start'),
                onPressed: onRun,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
