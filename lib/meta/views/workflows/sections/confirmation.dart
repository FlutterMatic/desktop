// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/inputs/check_box_element.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';

class SetProjectWorkflowConfirmation extends StatelessWidget {
  final String projectName;
  final String workflowName;
  final String workflowDescription;
  final bool addToGitignore;
  final bool addAllToGitignore;
  final Function() onSave;
  final Function() onSaveAndRun;
  final Function() onAddToGitignore;
  final Function() onAddAllToGitignore;

  const SetProjectWorkflowConfirmation({
    Key? key,
    required this.projectName,
    required this.workflowName,
    required this.workflowDescription,
    required this.onSave,
    required this.onSaveAndRun,
    required this.addToGitignore,
    required this.onAddToGitignore,
    required this.addAllToGitignore,
    required this.onAddAllToGitignore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          SvgPicture.asset(Assets.confetti, height: 30, color: kYellowColor),
          VSeparators.large(),
          const Text(
            'Your project workflow is ready!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          VSeparators.small(),
          const SizedBox(
            width: 600,
            child: Text(
              'It worked out! You can check your workflows in the projects tab and run whichever workflow you want. Also, you can run your workflow for the first time by clicking the "Save and Run" button in the workflow tab.',
              textAlign: TextAlign.center,
            ),
          ),
          VSeparators.xLarge(),
          RoundContainer(
            width: 450,
            child: Column(
              children: <Widget>[
                CheckBoxElement(
                  value: addToGitignore,
                  onChanged: (_) => onAddToGitignore(),
                  text: 'Add this workflow only to my .gitignore file',
                ),
                VSeparators.xSmall(),
                RoundContainer(
                  width: double.infinity,
                  height: 2,
                  color: Colors.blueGrey.withOpacity(0.3),
                  child: const SizedBox.shrink(),
                ),
                VSeparators.xSmall(),
                CheckBoxElement(
                  onChanged: (_) => onAddAllToGitignore(),
                  value: addAllToGitignore,
                  text:
                      'Add all workflows for this project to my .gitignore file',
                ),
              ],
            ),
          ),
          VSeparators.large(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RectangleButton(
                width: 150,
                child: const Text('Save'),
                onPressed: onSave,
              ),
              HSeparators.normal(),
              RectangleButton(
                width: 150,
                child: const Text('Save and Run'),
                onPressed: onSaveAndRun,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
