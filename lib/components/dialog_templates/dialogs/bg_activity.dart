import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/dialog_header.dart';
import 'package:flutter_installer/components/widgets/dialog_template.dart';
import 'package:flutter_installer/components/widgets/rectangle_button.dart';
import 'package:flutter_installer/utils/constants.dart';

class BgActivityDialog extends StatefulWidget {
  @override
  _BgActivityDialogState createState() => _BgActivityDialogState();
}

class _BgActivityDialogState extends State<BgActivityDialog> {
  List<Widget> _activities = [];

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
    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DialogHeader(title: 'Background Activity'),
          const SizedBox(height: 30),
          const Text(
            'Activity',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          _activities.isEmpty
              ? const Text(
                  'No background activity running at the moment. Check back later.')
              : Column(
                  children: bgActivities.isEmpty
                      ? _activities.map((val) => val).toList(growable: true)
                      : bgActivities.map((val) => val).toList(growable: true),
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
