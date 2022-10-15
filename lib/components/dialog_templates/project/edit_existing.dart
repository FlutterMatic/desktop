// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/dialog_templates/project/create/common/dependencies.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/inputs/text_field.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/load_activity_msg.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/components/widgets/ui/stage_tile.dart';
import 'package:fluttermatic/core/notifiers/models/state/actions/projects.dart';
import 'package:fluttermatic/core/notifiers/notifiers/actions/projects.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/meta/utils/general/app_theme.dart';
import 'package:fluttermatic/meta/utils/general/extract_pubspec.dart';

class EditExistingProjectDialog extends StatefulWidget {
  final String projectPath;

  const EditExistingProjectDialog({Key? key, required this.projectPath})
      : super(key: key);

  @override
  _EditExistingProjectDialogState createState() =>
      _EditExistingProjectDialogState();
}

class _EditExistingProjectDialogState extends State<EditExistingProjectDialog> {
  // Inputs
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _projectDescriptionController =
      TextEditingController();

  // Dependencies
  final List<String> _dependencies = <String>[];
  final List<String> _devDependencies = <String>[];

  // Utils
  PubspecInfo? _pubspecInfo;

  Future<void> _loadData() async {
    File pubspec = File('${widget.projectPath}\\pubspec.yaml');

    List<String> lines = await pubspec.readAsLines();

    setState(() {
      _pubspecInfo = extractPubspec(lines: lines, path: pubspec.path);
      _projectNameController.text = _pubspecInfo?.name ?? 'No project name set';
      _projectDescriptionController.text =
          _pubspecInfo?.description ?? 'No project description set';

      if (_pubspecInfo != null) {
        _dependencies
            .addAll(_pubspecInfo!.dependencies.map((e) => e.name).toList());
        _devDependencies
            .addAll(_pubspecInfo!.devDependencies.map((e) => e.name).toList());
      }
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        ProjectsState projectsState = ref.watch(projectsActionStateNotifier);
        ProjectsNotifier projectsNotifier =
            ref.watch(projectsActionStateNotifier.notifier);

        return WillPopScope(
          onWillPop: () async => !projectsState.loading,
          child: DialogTemplate(
            outerTapExit: !projectsState.loading,
            child: Column(
              children: <Widget>[
                DialogHeader(
                  title: 'Edit Project',
                  canClose: !projectsState.loading,
                  leading: const StageTile(),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: Builder(
                    builder: (_) {
                      if (projectsState.loading) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            if (projectsState.currentActivity
                                .startsWith('Removing ')) ...<Widget>[
                              informationWidget(
                                  'Removing packages may take a while. This is because your unneeded pub cache is being deleted which contains information and the code for each individual package.'),
                              VSeparators.normal(),
                            ],
                            LoadActivityMessageElement(
                                message: projectsState.currentActivity),
                          ],
                        );
                      } else if (_pubspecInfo != null &&
                          !_pubspecInfo!.isValid) {
                        return Column(
                          children: <Widget>[
                            informationWidget(
                                'This project is not supported by Fluttermatic. pubspec.yaml file is invalidly formatted.'),
                            VSeparators.normal(),
                            RectangleButton(
                              child: const Text('OK'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        );
                      } else {
                        return SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              RoundContainer(
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    CustomTextField(
                                        hintText: 'Project Name',
                                        controller: _projectNameController),
                                    VSeparators.xSmall(),
                                    CustomTextField(
                                      readOnly:
                                          _pubspecInfo?.description == null,
                                      hintText: 'Project Description',
                                      controller: _projectDescriptionController,
                                      numLines:
                                          _pubspecInfo?.description != null
                                              ? 3
                                              : 1,
                                      maxLength:
                                          _pubspecInfo?.description != null
                                              ? 150
                                              : null,
                                    ),
                                  ],
                                ),
                              ),
                              VSeparators.small(),
                              ProjectDependenciesSection(
                                dependencies: _pubspecInfo == null
                                    ? []
                                    : _pubspecInfo!.dependencies
                                        .map((_) => _.name)
                                        .toList(),
                                devDependencies: _pubspecInfo == null
                                    ? []
                                    : _pubspecInfo!.devDependencies
                                        .map((_) => _.name)
                                        .toList(),
                                onDependenciesChanged: (List<String> e) {
                                  _dependencies.clear();
                                  _dependencies.addAll(e);
                                },
                                onDevDependenciesChanged: (List<String> e) {
                                  _devDependencies.clear();
                                  _devDependencies.addAll(e);
                                },
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
                if (!projectsState.loading &&
                    _pubspecInfo != null &&
                    _pubspecInfo!.isValid) ...<Widget>[
                  VSeparators.normal(),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: RectangleButton(
                          hoverColor: AppTheme.errorColor,
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      HSeparators.normal(),
                      Expanded(
                        child: RectangleButton(
                          onPressed: () async {
                            await projectsNotifier.updateProjectInfo(
                              context,
                              projectPath: widget.projectPath,
                              projectName: _projectNameController.text,
                              projectDescription:
                                  _projectDescriptionController.text,
                              dependencies: _dependencies,
                              devDependencies: _devDependencies,
                              pubspecInfo: _pubspecInfo!,
                            );

                            if (!projectsState.loading &&
                                !projectsState.error) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  snackBarTile(
                                    context,
                                    'Your project has been updated.',
                                    type: SnackBarType.done,
                                  ),
                                );

                                Navigator.pop(context);
                              }

                              return;
                            }

                            if (mounted) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                snackBarTile(
                                  context,
                                  'Something went wrong. Please try again.',
                                  type: SnackBarType.error,
                                ),
                              );
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
