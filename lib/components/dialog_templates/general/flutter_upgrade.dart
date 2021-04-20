import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/dialog_header.dart';
import 'package:flutter_installer/components/widgets/dialog_template.dart';
import 'package:flutter_installer/components/widgets/rectangle_button.dart';
import 'package:flutter_installer/utils/constants.dart';

class LatestFlutterDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DialogHeader(title: 'Flutter Upgrade'),
          const SizedBox(height: 30),
          const Icon(Icons.check_circle, size: 40, color: kGreenColor),
          const SizedBox(height: 20),
          Text('$flutterChannel - v$flutterVersion',
              style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          Text(
              'You are on the latest version of the $flutterChannel channel! Check back later.'),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class NewFlutterDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DialogHeader(title: 'New Flutter Version'),
          const SizedBox(height: 30),
          const Icon(Iconsdata.download, size: 50, color: kGreenColor),
          const SizedBox(height: 30),
          Text(
            'You have a new $flutterChannel version. You can update your Flutter version and still continue using Flutter.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          RectangleButton(
            width: double.infinity,
            color: Colors.blueGrey,
            splashColor: Colors.blueGrey.withOpacity(0.5),
            focusColor: Colors.blueGrey.withOpacity(0.5),
            hoverColor: Colors.grey.withOpacity(0.5),
            highlightColor: Colors.blueGrey.withOpacity(0.5),
            onPressed: () {},
            child: const Text('Update Flutter'),
          ),
        ],
      ),
    );
  }
}

class CheckFlutterVersionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DialogHeader(title: 'Latest Flutter Version'),
          const SizedBox(height: 40),
          const CircularProgressIndicator(),
          const SizedBox(height: 30),
          const Text('Checking for any Flutter updates. Shouldn\'t take long.'),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
