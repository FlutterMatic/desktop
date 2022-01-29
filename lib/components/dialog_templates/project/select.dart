// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/dialog_templates/project/dart/new_dart.dart';
import 'package:fluttermatic/components/dialog_templates/project/flutter/new_flutter.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';

class SelectProjectTypeDialog extends StatelessWidget {
  const SelectProjectTypeDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          const DialogHeader(title: 'Select Type'),
          infoWidget(context,
              'We will guide you through all the necessary steps to create a new Flutter or Dart project.'),
          VSeparators.normal(),
          Row(
            children: <Widget>[
              Expanded(
                child: RectangleButton(
                  height: 100,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                          child: SvgPicture.asset(Assets.flutter, height: 25)),
                      VSeparators.normal(),
                      const Text('Flutter'),
                    ],
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (_) => const NewFlutterProjectDialog(),
                    );
                  },
                ),
              ),
              HSeparators.normal(),
              Expanded(
                child: RectangleButton(
                  height: 100,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                          child: SvgPicture.asset(Assets.dart, height: 25)),
                      VSeparators.normal(),
                      const Text('Dart'),
                    ],
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (_) => const NewDartProjectDialog(),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
