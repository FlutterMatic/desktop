import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/dialog_header.dart';
import 'package:flutter_installer/components/widgets/ui/activity_tile.dart';
import 'package:flutter_installer/components/widgets/ui/dialog_template.dart';
import 'package:flutter_installer/components/widgets/buttons/rectangle_button.dart';
import 'package:flutter_installer/components/widgets/ui/round_container.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'dart:async';

class BgActivityDialog extends StatefulWidget {
  @override
  _BgActivityDialogState createState() => _BgActivityDialogState();
}

class _BgActivityDialogState extends State<BgActivityDialog> {
  List<BgActivityTile> _activities = [];

  void _activateReload() {
    _activities.clear();
    if (mounted) {
      setState(() => _activities = bgActivities);
    }
    Timer.periodic(const Duration(seconds: 5), (val) {
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
                      ? _activities.map((val) => val).toList(growable: true)
                      : bgActivities.map((val) => val).toList(growable: true),
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
