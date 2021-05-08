import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/dialog_header.dart';
import 'package:flutter_installer/components/widgets/dialog_template.dart';
import 'package:flutter_installer/components/widgets/rectangle_button.dart';
import 'package:flutter_installer/components/widgets/text_field.dart';
import 'package:flutter_installer/utils/constants.dart';

class RunCommandDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return DialogTemplate(
      child: Column(
        children: [
          DialogHeader(title: 'Run Flutter Command'),
          const SizedBox(height: 20),
          CustomTextField(
            hintText: 'Type Command',
            onChanged: (val) {},
          ),
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.centerRight,
            child: RectangleButton(
              onPressed: () {},
              width: 100,
              child: Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Run',
                      style: TextStyle(
                          color: customTheme.textTheme.bodyText1!.color!),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.play_arrow_rounded, color: kGreenColor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
