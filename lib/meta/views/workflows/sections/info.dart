// 🐦 Flutter imports:
import 'dart:io';

import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:file_selector/file_selector.dart' as file;
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/meta/utils/extract_pubspec.dart';
import 'package:manager/meta/views/workflows/components/input_hover.dart';

class SetProjectWorkflowInfo extends StatefulWidget {
  final Function() onNext;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final PubspecInfo? pubspecFile;
  final Function(PubspecInfo pubspec) onPubspecUpdate;
  final bool showLastPage;
  final bool disableChangePubspec;

  const SetProjectWorkflowInfo({
    Key? key,
    required this.disableChangePubspec,
    required this.onNext,
    required this.nameController,
    required this.descriptionController,
    required this.pubspecFile,
    required this.onPubspecUpdate,
    required this.showLastPage,
  }) : super(key: key);

  @override
  _SetProjectWorkflowInfoState createState() => _SetProjectWorkflowInfoState();
}

class _SetProjectWorkflowInfoState extends State<SetProjectWorkflowInfo> {
  bool _nameExists = false;
  bool _loadingExistingNames = false;

  int _selectedIndex = 0;

  @override
  void initState() {
    if (widget.showLastPage) {
      setState(() => _selectedIndex = 2);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stepper(
      physics: const NeverScrollableScrollPhysics(),
      currentStep: _selectedIndex,
      controlsBuilder: (_, ControlsDetails details) {
        return Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Row(
            children: <Widget>[
              if (_selectedIndex != 0)
                RectangleButton(
                  width: 100,
                  child: const Text('Back'),
                  onPressed: () => setState(() => _selectedIndex--),
                ),
              const Spacer(),
              RectangleButton(
                width: 100,
                child: const Text('Next'),
                onPressed: () {
                  if (_selectedIndex == 0) {
                    setState(() => _selectedIndex++);
                    return;
                  }

                  if (_selectedIndex == 1) {
                    // Validate the pubspec file.
                    if (widget.pubspecFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        snackBarTile(
                          context,
                          'Please select a pubspec.yaml file to continue setting up workflow.',
                          type: SnackBarType.error,
                          revert: true,
                        ),
                      );
                      return;
                    }

                    // Make sure that the pubspec has the name and version tag.
                    if (!_validatePubspec(widget.pubspecFile!)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        snackBarTile(
                          context,
                          'Please add the required parameters to the pubspec.yaml file to continue setting up workflow.',
                          type: SnackBarType.error,
                          action: snackBarAction(
                            text: 'Learn more',
                            onPressed: () {},
                          ),
                          revert: true,
                        ),
                      );
                      return;
                    }

                    setState(() => _selectedIndex++);
                    return;
                  }

                  // Validate the name and description tag.
                  if (_selectedIndex == 2) {
                    bool _isValidNameAndDescription =
                        _validateNameAndDescription(
                            context: context,
                            descriptionController: widget.descriptionController,
                            nameController: widget.nameController);
                    if (_isValidNameAndDescription) {
                      if (_nameExists || _loadingExistingNames) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          snackBarTile(
                            context,
                            'The workflow name you have chosen already exists. Please choose another workflow name.',
                            type: SnackBarType.error,
                            revert: true,
                          ),
                        );

                        return;
                      } else {
                        // Go to the next page that is handled by the parent.
                        widget.onNext();
                        return;
                      }
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
      steps: <Step>[
        Step(
          state: _getStepState(_selectedIndex, 0),
          title: const Text('Getting Started'),
          subtitle: const Text(
              'Start using and integrating workflows into your apps.'),
          content: informationWidget(
            'Workflow actions help you run actions on your Flutter or Dart projects directly from this app. You can setup a script to run tests, analyze your code, fetch new package version, and more.',
            type: InformationType.green,
          ),
        ),
        Step(
          state: _getStepState(_selectedIndex, 1),
          title: const Text('Project pubspec.yaml file'),
          subtitle: const Text(
              'Add your app\'s pubspec.yaml file to continue integrating the workflow.'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 2,
                color: Colors.blueGrey.withOpacity(0.2),
              ),
              VSeparators.normal(),
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'Select your Flutter or Dart project pubspec.yaml file. We will use this to make sure it\'s a valid project. Workflow config information will be set in a new file called fm_config.json.',
                    ),
                  ),
                  HSeparators.normal(),
                  RoundContainer(
                    padding: EdgeInsets.zero,
                    borderColor: Colors.blueGrey.withOpacity(0.5),
                    child: RectangleButton(
                      disable: widget.disableChangePubspec,
                      width: 120,
                      child: Text(
                          widget.pubspecFile == null ? 'Select' : 'Change'),
                      onPressed: () async {
                        file.XFile? _file = await file.openFile();
                        if (_file == null && widget.pubspecFile != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            snackBarTile(
                              context,
                              'You can still change this file if you changed your mind.',
                              revert: true,
                            ),
                          );
                          return;
                        }

                        if (_file == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            snackBarTile(
                              context,
                              'You must select a pubspec.yaml file to continue setting up this workflow.',
                              type: SnackBarType.error,
                              revert: true,
                            ),
                          );
                          return;
                        }

                        if (!_file.path.endsWith('\\pubspec.yaml')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            snackBarTile(
                              context,
                              'Invalid file selected. The file must be named pubspec.yaml.',
                              type: SnackBarType.error,
                              revert: true,
                            ),
                          );
                          return;
                        }

                        PubspecInfo _pubspec = extractPubspec(
                          lines: await _file
                              .readAsString()
                              .then((String value) => value.split('\n')),
                          path: _file.path,
                        );

                        widget.onPubspecUpdate(_pubspec);

                        ScaffoldMessenger.of(context).showSnackBar(
                          snackBarTile(
                            context,
                            'Your pubspec.yaml file has been added successfully.',
                            type: SnackBarType.done,
                            revert: true,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (widget.pubspecFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: <Widget>[
                      VSeparators.small(),
                      Container(
                        width: double.infinity,
                        height: 2,
                        color: Colors.grey.withOpacity(0.2),
                      ),
                      VSeparators.normal(),
                      Builder(
                        builder: (_) {
                          String _header = '';

                          _header = (widget.pubspecFile?.name ?? 'Unknown')
                              .toUpperCase();

                          _header += ' - ';

                          _header +=
                              widget.pubspecFile?.version ?? 'No version';

                          return Row(
                            children: <Widget>[
                              SvgPicture.asset(Assets.done, height: 20),
                              HSeparators.normal(),
                              Expanded(child: Text(_header)),
                              if (widget.pubspecFile?.isFlutterProject == true)
                                Tooltip(
                                  message: 'This is a Flutter project.',
                                  child: SvgPicture.asset(Assets.flutter,
                                      height: 20),
                                ),
                              HSeparators.normal(),
                              Tooltip(
                                message:
                                    'This is a Dart project. Any Flutter project is a Dart project.',
                                child:
                                    SvgPicture.asset(Assets.dart, height: 20),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              VSeparators.xLarge(),
            ],
          ),
        ),
        Step(
          state: _getStepState(_selectedIndex, 2),
          title: const Text('Workflow Information'),
          subtitle:
              const Text('Set up the name and description of your workflow.'),
          content: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: InputHoverAffect(
                      controller: widget.nameController,
                      hintText: 'Workflow name',
                      infoText: 'You can change the name later.',
                      onChanged: (String val) async {
                        setState(() => _loadingExistingNames = true);
                        File _file = File(widget.pubspecFile!.pathToPubspec!
                                .replaceAll('\\pubspec.yaml', '') +
                            '\\f_matic\\${widget.nameController.text}.json');

                        if (await _file.exists()) {
                          setState(() => _nameExists = true);
                        } else {
                          setState(() => _nameExists = false);
                        }

                        setState(() => _loadingExistingNames = false);
                      },
                    ),
                  ),
                  if (_loadingExistingNames)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Spinner(thickness: 2, size: 15),
                    ),
                  if (_nameExists)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Tooltip(
                        message: 'This name already exists.',
                        child: SvgPicture.asset(Assets.error, height: 20),
                      ),
                    ),
                ],
              ),
              VSeparators.normal(),
              InputHoverAffect(
                controller: widget.descriptionController,
                hintText: 'Workflow description',
                infoText:
                    'Describe what your workflow will do. This description will be shown in the workflow list.',
                numLines: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

StepState _getStepState(int currentIndex, int stepIndex) {
  if (currentIndex <= stepIndex) {
    if (currentIndex == stepIndex) {
      return StepState.editing;
    } else {
      return StepState.indexed;
    }
  } else {
    return StepState.complete;
  }
}

bool _validateNameAndDescription({
  required BuildContext context,
  required TextEditingController nameController,
  required TextEditingController descriptionController,
}) {
  if (nameController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      snackBarTile(
        context,
        'You must enter a name for this workflow.',
        type: SnackBarType.error,
        revert: true,
      ),
    );
    return false;
  }

  if (descriptionController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      snackBarTile(
        context,
        'You must enter a description for this workflow.',
        type: SnackBarType.error,
        revert: true,
      ),
    );

    return false;
  }

  return true;
}

bool _validatePubspec(PubspecInfo pubspec) {
  List<bool> _conditions = <bool>[
    pubspec.name != null && pubspec.name!.isNotEmpty,
    pubspec.version != null && pubspec.version!.isNotEmpty,
  ];

  return !_conditions.contains(false);
}
