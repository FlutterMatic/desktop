// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/inputs/text_field.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/load_activity_msg.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/core/notifiers/models/state/actions/projects.dart';
import 'package:fluttermatic/core/notifiers/notifiers/actions/projects.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/meta/utils/general/app_theme.dart';
import 'package:fluttermatic/meta/utils/general/extract_pubspec.dart';

class DeleteProjectDialog extends StatefulWidget {
  final String path;

  const DeleteProjectDialog({Key? key, required this.path}) : super(key: key);

  @override
  _DeleteProjectDialogState createState() => _DeleteProjectDialogState();
}

class _DeleteProjectDialogState extends State<DeleteProjectDialog> {
  late final bool _gitExists = Directory('${widget.path}\\.git').existsSync();

  late final PubspecInfo _pubspecInfo = extractPubspec(
    lines: File('${widget.path}\\pubspec.yaml').readAsLinesSync(),
    path: widget.path,
  );

  // Inputs
  String _confirmText = '';

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        ProjectsState projectsState = ref.watch(projectsActionStateNotifier);
        ProjectsNotifier projectsNotifier =
            ref.watch(projectsActionStateNotifier.notifier);

        return WillPopScope(
          onWillPop: () => Future.value(!projectsState.loading),
          child: DialogTemplate(
            outerTapExit: !projectsState.loading,
            child: IgnorePointer(
              ignoring: projectsState.loading,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  DialogHeader(
                      title: 'Delete Project',
                      canClose: !projectsState.loading),
                  if (_gitExists)
                    informationWidget(
                        'You are about to delete this project from your device. We also found that this project is on a git repository, so you should be able to recover it if you ever want to.',
                        type: InformationType.green)
                  else
                    informationWidget(
                        'This project is NOT a git repository. Please be aware that after you delete this project, you will not be able to recover it.'),
                  VSeparators.normal(),
                  RoundContainer(
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
                              child: Builder(
                                builder: (_) {
                                  String version = 'No version found';

                                  if (_pubspecInfo.version != null) {
                                    version =
                                        '${_pubspecInfo.version!.major}.${_pubspecInfo.version!.minor}.${_pubspecInfo.version!.patch}-${_pubspecInfo.version!.preRelease.isNotEmpty ? _pubspecInfo.version!.preRelease.first : 'stable'}';
                                  }

                                  return Text(
                                    '${_pubspecInfo.name?.toUpperCase() ?? 'No name found'} - $version',
                                    maxLines: 1,
                                  );
                                },
                              ),
                            ),
                            HSeparators.normal(),
                            if (!_pubspecInfo.isValid)
                              SvgPicture.asset(Assets.error, height: 15)
                            else ...<Widget>[
                              if (_pubspecInfo.isFlutterProject)
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: SvgPicture.asset(Assets.flutter,
                                      height: 15),
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
                      'To confirm delete, please type "DELETE", all caps.'),
                  VSeparators.normal(),
                  CustomTextField(
                    hintText: 'Confirm Delete',
                    onChanged: (String val) =>
                        setState(() => _confirmText = val),
                  ),
                  VSeparators.normal(),
                  if (projectsState.loading)
                    const LoadActivityMessageElement(
                      message: 'Deleting Project...',
                    )
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  snackBarTile(
                                    context,
                                    'Please type "DELETE" to confirm deleting this project.',
                                    type: SnackBarType.error,
                                  ),
                                );
                                return;
                              }

                              await projectsNotifier.deleteProject(widget.path);

                              // Deleted successfully.
                              if (!projectsState.error && mounted) {
                                Navigator.pop(context);
                              }
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
      },
    );
  }
}
