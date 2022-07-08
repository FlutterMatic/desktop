// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/meta/views/dialogs/open_project.dart';

class ProjectCreatedDialog extends StatelessWidget {
  final String projectName;
  final String projectPath;

  const ProjectCreatedDialog({
    Key? key,
    required this.projectName,
    required this.projectPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const DialogHeader(title: 'Project Created'),
          const Text(
              'Your new project has successfully been created. You should be able to open your project and run it!',
              textAlign: TextAlign.center),
          VSeparators.large(),
          infoWidget(context,
              'If you are new here, take some time to read the documentation and how you can automate some workflows you do day to day in your Flutter/Dart environment.'),
          VSeparators.large(),
          Row(
            children: <Widget>[
              Expanded(
                child: RectangleButton(
                  width: double.infinity,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      snackBarTile(
                        context,
                        'You can still find your project in the Projects tab.',
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ),
              HSeparators.small(),
              Expanded(
                child: RectangleButton(
                  width: double.infinity,
                  onPressed: () async {
                    Navigator.pop(context);
                    await showDialog(
                      context: context,
                      builder: (_) => OpenProjectInEditor(path: projectPath),
                    );
                  },
                  child: const Text('Open in Editor'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
