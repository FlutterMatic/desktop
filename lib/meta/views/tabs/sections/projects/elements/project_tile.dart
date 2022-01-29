// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/dialog_templates/text_field.dart';
import 'package:fluttermatic/components/widgets/buttons/action_options.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/beta_tile.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/load_activity_msg.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';
import 'package:fluttermatic/meta/utils/extract_pubspec.dart';
import 'package:fluttermatic/meta/views/dialogs/open_project.dart';
import 'package:fluttermatic/meta/views/tabs/home.dart';
import 'package:fluttermatic/meta/views/tabs/sections/projects/projects.dart';
import 'package:fluttermatic/meta/views/workflows/startup.dart';
import 'package:fluttermatic/meta/views/workflows/views/existing_workflows.dart';

class ProjectInfoTile extends StatefulWidget {
  final String name;
  final String? description;
  final DateTime modDate;
  final String path;

  const ProjectInfoTile({
    Key? key,
    required this.name,
    required this.description,
    required this.modDate,
    required this.path,
  }) : super(key: key);

  @override
  State<ProjectInfoTile> createState() => _ProjectInfoTileState();
}

class _ProjectInfoTileState extends State<ProjectInfoTile> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: RoundContainer(
        height: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    widget.name,
                    style: const TextStyle(fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
                if (_isHovering)
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: RectangleButton(
                      padding: EdgeInsets.zero,
                      child: const Icon(Icons.more_vert, size: 14),
                      color: Colors.transparent,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) =>
                              _ProjectOptionsDialog(path: widget.path),
                        );
                      },
                      radius: BorderRadius.circular(2),
                      width: 22,
                      height: 22,
                    ),
                  ),
              ],
            ),
            VSeparators.normal(),
            Expanded(
              child: Text(
                widget.description ?? 'No project description found.',
                style: const TextStyle(color: Colors.grey),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
            if (_isHovering)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Tooltip(
                  waitDuration: const Duration(milliseconds: 500),
                  message: widget.path,
                  child: Text(
                    widget.path,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ),
            VSeparators.small(),
            Text(
              'Modified date: ${toMonth(widget.modDate.month)} ${widget.modDate.day}, ${widget.modDate.year}',
              maxLines: 2,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: TextStyle(color: Colors.grey[700]),
            ),
            VSeparators.normal(),
            Row(
              children: <Widget>[
                Expanded(
                  child: RectangleButton(
                    child: const Text('Open Project'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => OpenProjectInEditor(path: widget.path),
                      );
                    },
                  ),
                ),
                HSeparators.xSmall(),
                HSeparators.xSmall(),
                RectangleButton(
                  width: 40,
                  height: 40,
                  padding: EdgeInsets.zero,
                  child:
                      const Icon(Icons.play_arrow_rounded, color: kGreenColor),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) =>
                          ShowExistingWorkflows(pubspecPath: widget.path),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectOptionsDialog extends StatefulWidget {
  final String path;

  const _ProjectOptionsDialog({
    Key? key,
    required this.path,
  }) : super(key: key);

  @override
  __ProjectOptionsDialogState createState() => __ProjectOptionsDialogState();
}

class __ProjectOptionsDialogState extends State<_ProjectOptionsDialog> {
  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          const DialogHeader(
            title: 'Project Options',
            leading: StageTile(stageType: StageType.alpha),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: RectangleButton(
                  height: 100,
                  child: Column(
                    children: <Widget>[
                      const Expanded(child: Icon(Icons.edit, size: 30)),
                      VSeparators.normal(),
                      const Text('Edit'),
                    ],
                  ),
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
                        child: Icon(Icons.delete_forever,
                            color: AppTheme.errorColor, size: 30),
                      ),
                      VSeparators.normal(),
                      const Text('Delete Project'),
                    ],
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => _DeleteProjectDialog(path: widget.path),
                    );
                  },
                ),
              ),
            ],
          ),
          VSeparators.normal(),
          ActionOptions(
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

class _DeleteProjectDialog extends StatefulWidget {
  final String path;
  const _DeleteProjectDialog({Key? key, required this.path}) : super(key: key);

  @override
  __DeleteProjectDialogState createState() => __DeleteProjectDialogState();
}

class __DeleteProjectDialogState extends State<_DeleteProjectDialog> {
  late final bool _gitExists = Directory(widget.path + '\\.git').existsSync();

  late final PubspecInfo _pubspecInfo = extractPubspec(
      lines: File(widget.path + '\\pubspec.yaml').readAsLinesSync(),
      path: widget.path);

  // Inputs
  String _confirmText = '';

  // Utils
  bool _deleting = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_deleting,
      child: DialogTemplate(
        outerTapExit: !_deleting,
        child: IgnorePointer(
          ignoring: _deleting,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DialogHeader(
                title: 'Delete Project',
                leading: const StageTile(),
                canClose: !_deleting,
              ),
              if (_gitExists)
                informationWidget(
                    'You are about to delete this project from your device. We also found that this project is on a git repository, so you should be able to recover it if you ever want to.',
                    type: InformationType.green)
              else
                informationWidget(
                    'This project is NOT a git repository. Please be aware that after you delete this project, you will not be able to recover it.'),
              VSeparators.normal(),
              RoundContainer(
                color: Colors.blueGrey.withOpacity(0.2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Project Path',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    VSeparators.xSmall(),
                    Tooltip(
                      message: widget.path,
                      waitDuration: const Duration(seconds: 1),
                      child: Text(
                        widget.path,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                    ),
                    VSeparators.small(),
                    const RoundContainer(
                      height: 2,
                      width: double.infinity,
                      padding: EdgeInsets.zero,
                      child: SizedBox.shrink(),
                    ),
                    VSeparators.small(),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            (_pubspecInfo.name?.toUpperCase() ??
                                    'No name found') +
                                ' - ' +
                                (_pubspecInfo.version ?? 'No version found'),
                            maxLines: 1,
                          ),
                        ),
                        HSeparators.normal(),
                        if (!_pubspecInfo.isValid)
                          SvgPicture.asset(Assets.error, height: 15)
                        else ...<Widget>[
                          if (_pubspecInfo.isFlutterProject)
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child:
                                  SvgPicture.asset(Assets.flutter, height: 15),
                            ),
                          SvgPicture.asset(Assets.dart, height: 15)
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              VSeparators.normal(),
              const Text(
                  'To confirm delete, please type "DELETE", case-sensitive.'),
              VSeparators.normal(),
              CustomTextField(
                hintText: 'Confirm Delete',
                onChanged: (String val) => setState(() => _confirmText = val),
              ),
              VSeparators.normal(),
              if (_deleting)
                const LoadActivityMessageElement(message: 'Deleting Project...')
              else
                Row(
                  children: <Widget>[
                    Expanded(
                      child: RectangleButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    HSeparators.normal(),
                    Expanded(
                      child: RectangleButton(
                        hoverColor: AppTheme.errorColor,
                        child: const Text('Delete'),
                        onPressed: () async {
                          if (_confirmText != 'DELETE') {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBarTile(
                              context,
                              'Please type DELETE to confirm deleting this project.',
                              type: SnackBarType.error,
                            ));
                            return;
                          }

                          setState(() => _deleting = true);

                          await logger.file(LogTypeTag.info,
                              'Deleting project: ${widget.path}');

                          try {
                            await Directory(widget.path)
                                .delete(recursive: true);

                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              snackBarTile(
                                context,
                                'Project has been deleted successfully.',
                                type: SnackBarType.done,
                              ),
                            );

                            await Navigator.pushReplacement(
                              context,
                              PageRouteBuilder<Widget>(
                                transitionDuration: Duration.zero,
                                pageBuilder: (_, __, ___) =>
                                    const HomeScreen(tab: HomeTab.projects),
                              ),
                            );

                            return;
                          } catch (_, s) {
                            await logger.file(LogTypeTag.error,
                                'Failed to delete project: ${widget.path}: $_',
                                stackTraces: s);

                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              snackBarTile(
                                context,
                                'Failed to delete project. Please try again.',
                                type: SnackBarType.error,
                              ),
                            );
                          }

                          setState(() => _deleting = false);
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
