// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/dialog_templates/project/edit_existing.dart';
import 'package:fluttermatic/components/dialog_templates/project/outdated_dependencies.dart';
import 'package:fluttermatic/components/widgets/buttons/action_options.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/coming_soon.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/meta/utils/general/app_theme.dart';
import 'package:fluttermatic/meta/views/tabs/sections/projects/dialogs/delete_project.dart';
import 'package:fluttermatic/meta/views/workflows/startup.dart';
import 'package:fluttermatic/meta/views/workflows/views/existing.dart';

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
                      const Expanded(
                          child: Center(child: Icon(Icons.edit, size: 30))),
                      VSeparators.normal(),
                      const Text('Edit'),
                    ],
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (_) =>
                          EditExistingProjectDialog(projectPath: widget.path),
                    );
                  },
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
                    Navigator.pop(context);
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
              if ('Create Release'.contains(action.title)) {
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
                      pubspecPath: '${widget.path}\\pubspec.yaml'),
                );
              }),
              ActionOptionsObject('Scan pubspec.yaml for new updates', () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => ScanProjectOutdatedDependenciesDialog(
                    pubspecPath: '${widget.path}\\pubspec.yaml',
                  ),
                );
              }),
              // TODO: Support the following option:
              ActionOptionsObject('Create Release', () {}),
            ],
          ),
        ],
      ),
    );
  }
}
