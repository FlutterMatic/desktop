// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/components/widgets/buttons/rectangle_button.dart';
import 'package:manager/components/widgets/inputs/text_field.dart';
import 'package:manager/components/widgets/ui/dialog_template.dart';
import 'package:manager/components/widgets/ui/snackbar_tile.dart';
import 'package:manager/components/widgets/ui/warning_widget.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/core/libraries/utils.dart';

class ConfirmWorkflowDelete extends StatefulWidget {
  final String path;
  final Function(bool) onClose;

  const ConfirmWorkflowDelete({
    Key? key,
    required this.path,
    required this.onClose,
  }) : super(key: key);

  @override
  _ConfirmWorkflowDeleteState createState() => _ConfirmWorkflowDeleteState();
}

class _ConfirmWorkflowDeleteState extends State<ConfirmWorkflowDelete> {
  bool _loading = false;
  String _confirmValue = '';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_loading,
      child: DialogTemplate(
        outerTapExit: !_loading,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DialogHeader(title: 'Delete Workflow', canClose: !_loading),
            informationWidget(
              'Are you sure you want to delete this workflow? This action cannot be undone.',
              type: InformationType.warning,
            ),
            VSeparators.normal(),
            const Text(
                'To confirm delete, please type "DELETE", case-sensitive.'),
            VSeparators.normal(),
            CustomTextField(
              hintText: 'Confirm Delete',
              onChanged: (String e) => setState(() => _confirmValue = e),
            ),
            VSeparators.normal(),
            Row(
              children: <Widget>[
                Expanded(
                  child: RectangleButton(
                    child: const Text('Cancel'),
                    onPressed: () async {
                      if (!_loading) {
                        await widget.onClose(false);
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
                HSeparators.normal(),
                Expanded(
                  child: RectangleButton(
                    loading: _loading,
                    child: const Text('Delete'),
                    color: AppTheme.errorColor,
                    onPressed: () async {
                      try {
                        if (_loading) {
                          return;
                        }
                        setState(() => _loading = true);
                        if (_confirmValue == 'DELETE') {
                          await File(widget.path).delete();
                          await logger.file(LogTypeTag.info,
                              'Deleted a workflow file from ${widget.path}');
                          await widget.onClose(true);
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context)
                              .showSnackBar(snackBarTile(
                            context,
                            'Please confirm by typing "DELETE". Input is case-sensitive.',
                            type: SnackBarType.error,
                          ));
                        }
                      } catch (_, s) {
                        await logger.file(
                            LogTypeTag.error, 'Failed to delete workflow',
                            stackTraces: s);
                        widget.onClose(false);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          snackBarTile(
                            context,
                            'Failed to delete workflow. Please try again.',
                            type: SnackBarType.error,
                          ),
                        );
                      }
                      setState(() => _loading = false);
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
