// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/select_tiles.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';

class DartProjectTemplateSection extends StatefulWidget {
  final String selectedTemplate;
  final Function(String template) onTemplateSelected;

  const DartProjectTemplateSection({
    Key? key,
    required this.selectedTemplate,
    required this.onTemplateSelected,
  }) : super(key: key);

  @override
  State<DartProjectTemplateSection> createState() =>
      _DartProjectTemplateSectionState();
}

class _DartProjectTemplateSectionState
    extends State<DartProjectTemplateSection> {
  final List<Map<String, String>> _tiles = <Map<String, String>>[];

  @override
  void initState() {
    dartCreateTemplates.forEach((String key, String value) {
      setState(() => _tiles.add(<String, String>{key: value}));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        infoWidget(context,
            'Choose your Dart template which will be used to generate your project.'),
        VSeparators.small(),
        RoundContainer(
          child: SelectTile(
            defaultValue: widget.selectedTemplate,
            options:
                _tiles.map((Map<String, String> e) => e.keys.first).toList(),
            onPressed: widget.onTemplateSelected,
          ),
        )
      ],
    );
  }
}

Map<String, String> dartCreateTemplates = <String, String>{
  'console-simple': 'A simple command-line application.',
  'console-full': 'A command-line application sample.',
  'package-simple': 'A starting point for Dart libraries or applications.',
  'server-shelf': 'A server app using `package:shelf`',
  'web-simple': 'A web app that uses only core Dart libraries.',
};
