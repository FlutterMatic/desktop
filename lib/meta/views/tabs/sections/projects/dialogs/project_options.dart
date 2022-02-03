// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/action_options.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/coming_soon.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';
import 'package:fluttermatic/meta/views/tabs/sections/projects/dialogs/delete_project.dart';
import 'package:fluttermatic/meta/views/workflows/startup.dart';
import 'package:fluttermatic/meta/views/workflows/views/existing_workflows.dart';

class ProjectOptionsDialog extends StatefulWidget {
  final String path;

  const ProjectOptionsDialog({
    Key? key,
    required this.path,
  }) : super(key: key);

  @override
  _ProjectOptionsDialogState createState() => _ProjectOptionsDialogState();
}

class _ProjectOptionsDialogState extends State<ProjectOptionsDialog> {
  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          const DialogHeader(title: 'Project Options'),
          Row(
            children: <Widget>[
              Expanded(
                child: RectangleButton(
                  height: 100,
                  child: Column(
                    children: <Widget>[
                      // const Expanded(child: Icon(Icons.edit, size: 30)),
                      // VSeparators.normal(),
                      const Expanded(child: Center(child: Text('Edit'))),
                      VSeparators.small(),
                      const ComingSoonTile(),
                    ],
                  ),
                  // TODO: Implement editing an existing project
                  onPressed: () {},
                ),
              ),
              HSeparators.normal(),
              Expanded(
                child: RectangleButton(
                  height: 100,
                  child: Column(
                    children: <Widget>[
                      const Expanded(
                        child: Center(
                          child: Icon(Icons.delete_forever,
                              color: AppTheme.errorColor, size: 30),
                        ),
                      ),
                      VSeparators.normal(),
                      const Text('Delete Project'),
                    ],
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => DeleteProjectDialog(path: widget.path),
                    );
                  },
                ),
              ),
            ],
          ),
          VSeparators.normal(),
          ActionOptions(
            actionButtonBuilder: (_, ActionOptionsObject action) {
              List<String> _comingSoon = <String>[
                'Scan pubspec.yaml for new updates',
                'Create Release',
              ];

              if (_comingSoon.contains(action.title)) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: ComingSoonTile(),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
            actions: <ActionOptionsObject>[
              ActionOptionsObject('Add Workflow', () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => StartUpWorkflow(pubspecPath: widget.path),
                );
              }),
              ActionOptionsObject('View Existing Workflow', () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => ShowExistingWorkflows(
                      pubspecPath: widget.path + '\\pubspec.yaml'),
                );
              }),
              // TODO: Support the following options:
              ActionOptionsObject('Scan pubspec.yaml for new updates', () {}),
              ActionOptionsObject('Create Release', () {}),
            ],
          ),
        ],
      ),
    );
  }
}
