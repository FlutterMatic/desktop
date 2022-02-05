// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/dialog_templates/project/create/add_dependencies.dart';
import 'package:fluttermatic/components/dialog_templates/project/create/common/dependencies.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/inputs/text_field.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/load_activity_msg.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/components/widgets/ui/stage_tile.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';
import 'package:fluttermatic/meta/utils/extract_pubspec.dart';

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
  bool _isLoading = true;
  late PubspecInfo _pubspecInfo;
  String _activityMessage = '';

  static const Duration _pubCommandDuration = Duration(seconds: 10);

  Future<void> _save() async {
    try {
      if (_projectNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
          context,
          'Please provide a name.',
          type: SnackBarType.error,
        ));
        return;
      }

      if (_projectDescriptionController.text.isEmpty) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
          context,
          'Please provide a description.',
          type: SnackBarType.error,
        ));
        return;
      }

      setState(() => _isLoading = true);

      // We will add each dependency to the pubspec.yaml file
      for (String dependency in _dependencies) {
        setState(() => _activityMessage = 'Adding dependency $dependency...');
        try {
          await addDependencyToProject(
            path: widget.projectPath,
            dependency: dependency,
            isDev: false,
            isDart: !_pubspecInfo.isFlutterProject,
          ).timeout(_pubCommandDuration);
        } catch (_) {
          // Ignore...
        }
      }

      for (String dependency in _devDependencies) {
        setState(
            () => _activityMessage = 'Adding dev dependency $dependency...');
        try {
          await addDependencyToProject(
            path: widget.projectPath,
            dependency: dependency,
            isDev: true,
            isDart: !_pubspecInfo.isFlutterProject,
          ).timeout(_pubCommandDuration);
        } catch (_) {
          // Ignore...
        }
      }

      // We will remove all the dependencies that are not in the list of
      // dependencies or dev dependencies.
      for (DependenciesInfo dependency in _pubspecInfo.dependencies) {
        bool _exists = false;

        for (String dependency2 in _dependencies) {
          if (dependency2 == dependency.name) {
            _exists = true;
            break;
          }
        }

        if (!_exists) {
          setState(() =>
              _activityMessage = 'Removing dependency ${dependency.name}...');
          try {
            await addDependencyToProject(
              path: widget.projectPath,
              dependency: dependency.name,
              isDev: false,
              isDart: !_pubspecInfo.isFlutterProject,
              remove: true,
            ).timeout(_pubCommandDuration);
          } catch (_) {
            // Ignore...
          }
        }
      }

      for (DependenciesInfo dependency in _pubspecInfo.devDependencies) {
        bool _exists = false;

        for (String dependency2 in _devDependencies) {
          if (dependency2 == dependency.name) {
            _exists = true;
            break;
          }
        }

        if (!_exists) {
          setState(() => _activityMessage =
              'Removing dev dependency ${dependency.name}...');
          try {
            await addDependencyToProject(
              path: widget.projectPath,
              dependency: dependency.name,
              isDev: false,
              isDart: !_pubspecInfo.isFlutterProject,
              remove: true,
            ).timeout(_pubCommandDuration);
          } catch (_) {
            // Ignore...
          }
        }
      }

      // We will update the pubspec.yaml file with the new name and description
      setState(() => _activityMessage = 'Updating pubspec.yaml...');
      List<String> pubspecLines =
          await File(widget.projectPath + '\\pubspec.yaml').readAsLines();

      bool _addedName = false;
      bool _addedDescription = false;

      // We will update the name and description
      for (int i = 0; i < pubspecLines.length; i++) {
        if (pubspecLines[i].startsWith('name: ')) {
          pubspecLines[i] = 'name: ${_projectNameController.text}';
          _addedName = true;
        } else if (pubspecLines[i].startsWith('description: ')) {
          pubspecLines[i] =
              'description: ${_projectDescriptionController.text}';
          _addedDescription = true;
        }

        if (_addedName && _addedDescription) {
          break;
        }
      }

      // We will now write the new pubspec.yaml file
      await File(widget.projectPath + '\\pubspec.yaml')
          .writeAsString(pubspecLines.join('\n'));

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
        context,
        'Updated your project information.',
        type: SnackBarType.done,
      ));

      Navigator.pop(context);
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Failed to save project edit: $_',
          stackTraces: s);
      setState(() {
        _isLoading = false;
        _activityMessage = '';
      });
    }
  }

  Future<void> _loadData() async {
    File _pubspec = File(widget.projectPath + '\\pubspec.yaml');

    List<String> _lines = await _pubspec.readAsLines();

    setState(() {
      _pubspecInfo = extractPubspec(lines: _lines, path: _pubspec.path);
      _projectNameController.text = _pubspecInfo.name ?? 'No name provided';
      _projectDescriptionController.text = _pubspecInfo.description ??
          'No description. Add this field manually.';
      _dependencies
          .addAll(_pubspecInfo.dependencies.map((_) => _.name).toList());
      _devDependencies.addAll(_pubspecInfo.devDependencies
          .map((DependenciesInfo e) => e.name)
          .toList());
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isLoading,
      child: DialogTemplate(
        outerTapExit: !_isLoading,
        child: Column(
          children: <Widget>[
            DialogHeader(
              title: 'Edit Project',
              canClose: !_isLoading,
              leading: const StageTile(stageType: StageType.prerelease),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: Builder(
                builder: (_) {
                  if (_isLoading) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (_activityMessage
                            .startsWith('Removing ')) ...<Widget>[
                          informationWidget(
                              'Removing packages may take a while. This is because your unneeded pub cache is being deleted which contains information and the code for each individual package.'),
                          VSeparators.normal(),
                        ],
                        LoadActivityMessageElement(message: _activityMessage),
                      ],
                    );
                  } else if (!_pubspecInfo.isValid) {
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
                                  readOnly: _pubspecInfo.description == null,
                                  hintText: 'Project Description',
                                  controller: _projectDescriptionController,
                                  numLines:
                                      _pubspecInfo.description != null ? 3 : 1,
                                  maxLength: _pubspecInfo.description != null
                                      ? 150
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          VSeparators.normal(),
                          ProjectDependenciesSection(
                            dependencies: _pubspecInfo.dependencies
                                .map((_) => _.name)
                                .toList(),
                            devDependencies: _pubspecInfo.devDependencies
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
            if (!_isLoading && _pubspecInfo.isValid) ...<Widget>[
              VSeparators.normal(),
              Row(
                children: <Widget>[
                  Expanded(
                    child: RectangleButton(
                      child: const Text('Cancel'),
                      hoverColor: AppTheme.errorColor,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  HSeparators.normal(),
                  Expanded(
                    child: RectangleButton(
                      child: const Text('Save'),
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
