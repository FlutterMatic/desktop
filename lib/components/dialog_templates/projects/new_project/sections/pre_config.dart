import 'package:flutter/material.dart';
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/core/libraries/widgets.dart';

class ProjectPreConfigSection extends StatefulWidget {
  const ProjectPreConfigSection({Key? key}) : super(key: key);

  @override
  _ProjectPreConfigSectionState createState() =>
      _ProjectPreConfigSectionState();
}

class _ProjectPreConfigSectionState extends State<ProjectPreConfigSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RoundContainer(
          color: Colors.blueGrey.withOpacity(0.2),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    const Text(
                      'Have a Firebase backend you want to connect to?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    VSeparators.small(),
                    const Text(
                      'Upload your "google-services.json" file if you want to automatically setup Firebase.',
                    ),
                  ],
                ),
              ),
              HSeparators.normal(),
              RectangleButton(
                child: const Text('Upload'),
                width: 100,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
