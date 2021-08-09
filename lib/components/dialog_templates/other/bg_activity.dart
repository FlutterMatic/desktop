import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/components/widgets/buttons/rectangle_button.dart';
import 'package:manager/components/widgets/ui/dialog_template.dart';
import 'package:manager/components/widgets/ui/round_container.dart';
import 'package:manager/components/widgets/ui/activity_tile.dart';
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
          DialogHeader(title: 'Background Activity'),
          const SizedBox(height: 30),
          const Text(
            'Activity',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 20),
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