// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
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
import 'package:fluttermatic/meta/views/tabs/home.dart';

class DeleteProjectDialog extends StatefulWidget {
  final String path;
  const DeleteProjectDialog({Key? key, required this.path}) : super(key: key);

  @override
  _DeleteProjectDialogState createState() => _DeleteProjectDialogState();
}

class _DeleteProjectDialogState extends State<DeleteProjectDialog> {
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
