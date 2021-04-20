import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/dialog_header.dart';
import 'package:flutter_installer/components/widgets/button_list.dart';
import 'package:flutter_installer/components/widgets/dialog_template.dart';
import 'package:flutter_installer/components/widgets/rectangle_button.dart';
import 'package:flutter_installer/components/widgets/warning_widget.dart';
import 'package:flutter_installer/utils/constants.dart';

class ChangeChannelDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DialogHeader(title: 'Change Channel'),
          const SizedBox(height: 15),
          const SelectableText(
            'Choose a new channel to switch to. Switching to a new channel may take a while. New resources will be installed on your machine. We recommned staying on the stable channel.',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 15),
          SelectTile(
            onPressed: (val) {},
            defaultValue: 'Stable',
            options: [
              'Master',
              'Stable',
              'Beta',
              'Dev',
            ],
          ),
          warningWidget(
              'We recommend staying on the stable channel for best development experience unless it\'s necessary.',
              Assets.warning,
              kYellowColor),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Text('Cancel'),
                ),
              ),
              const Spacer(),
              RectangleButton(
                radius: BorderRadius.circular(5),
                onPressed: () {},
                child: Text(
                  'Continue',
                  style:
                      TextStyle(color: customTheme.textTheme.bodyText1!.color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
