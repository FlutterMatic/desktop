// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';

class SetProjectWorkflowConfirmation extends StatelessWidget {
  final String projectName;
  final String workflowName;
  final String workflowDescription;
  final Function() onSave;
  final Function() onSaveAndRun;

  const SetProjectWorkflowConfirmation({
    Key? key,
    required this.projectName,
    required this.workflowName,
    required this.workflowDescription,
    required this.onSave,
    required this.onSaveAndRun,
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
