// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:path_provider/path_provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/load_activity_msg.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/main.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';

class ClearCacheDialog extends StatefulWidget {
  const ClearCacheDialog({Key? key}) : super(key: key);

  @override
  _ClearCacheDialogState createState() => _ClearCacheDialogState();
}

class _ClearCacheDialogState extends State<ClearCacheDialog> {
  bool _isClearing = false;

  Future<void> _clearCache() async {
    try {
      setState(() => _isClearing = true);

      Directory _dir = await getApplicationSupportDirectory();

      await _dir.delete(recursive: true);

      RestartWidget.restartApp(context);
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to clear FlutterMatic cache: $_',
          stackTraces: s);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
          context, 'Failed to clear FlutterMatic cache. Please try again.'));
      setState(() => _isClearing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isClearing,
      child: IgnorePointer(
        ignoring: _isClearing,
        child: DialogTemplate(
          outerTapExit: !_isClearing,
          child: Column(
            children: <Widget>[
              DialogHeader(title: 'Clear Cache', canClose: !_isClearing),
              infoWidget(context,
                  'Tools installed by FlutterMatic will not be deleted, however, you will still need to go through the setup process again.'),
              VSeparators.normal(),
              informationWidget(
                  'Are you sure you want to clear the cache? This will impact performance while the app attempts to regenerate the cache once you continue using FlutterMatic.'),
              VSeparators.normal(),
              if (_isClearing)
                const LoadActivityMessageElement(message: '')
              else
                Row(
                  children: <Widget>[
                    Expanded(
                      child: RectangleButton(
                        hoverColor: AppTheme.errorColor,
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    HSeparators.normal(),
                    Expanded(
                      child: RectangleButton(
                        hoverColor: AppTheme.errorColor,
                        child: const Text('Clear Cache'),
                        onPressed: _clearCache,
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
