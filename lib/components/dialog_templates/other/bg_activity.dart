import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class BgActivityDialog extends StatefulWidget {
  @override
  _BgActivityDialogState createState() => _BgActivityDialogState();
}

class _BgActivityDialogState extends State<BgActivityDialog> {
  List<BgActivityTile> _activities = <BgActivityTile>[];

  void _activateReload() {
    _activities.clear();
    if (mounted) {
      setState(() => _activities = bgActivities);
    }
    Timer.periodic(const Duration(seconds: 5), (Timer val) {
      _activities.clear();
      if (mounted) {
        setState(() => _activities = bgActivities);
      }
    });
  }

  @override
  void initState() {
    _activateReload();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);

    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const DialogHeader(title: 'Background Activity'),
          VSeparators.xLarge(),
          const Text(
            'Activity',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          VSeparators.small(),
          if (_activities.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: RoundContainer(
                color: customTheme.focusColor,
                child: const Text(
                  'There are currently no background activities running. Check back later.',
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: Column(
                  children: bgActivities.isEmpty
                      ? _activities.map((BgActivityTile val) => val).toList()
                      : bgActivities.map((BgActivityTile val) => val).toList(),
                ),
              ),
            ),
          VSeparators.large(),
          RectangleButton(
            width: double.infinity,
            color: Colors.blueGrey,
            splashColor: Colors.blueGrey.withOpacity(0.5),
            focusColor: Colors.blueGrey.withOpacity(0.5),
            hoverColor: Colors.grey.withOpacity(0.5),
            highlightColor: Colors.blueGrey.withOpacity(0.5),
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
