import 'package:flutter/material.dart';
import 'package:flutter_installer/components/button_list.dart';
import 'package:flutter_installer/components/dialog_template.dart';
import 'package:flutter_installer/components/rectangle_button.dart';
import 'package:flutter_installer/components/square_button.dart';

class ChangeChannelDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 40),
              const Spacer(),
              const Text('Select Channel', style: TextStyle(fontSize: 20)),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: SquareButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const SelectableText(
              'Choose a new channel to switch to. Switching to a new channel may take a while. New resources will be installed on your machine. We recommned staying on the stable channel.',
              style: TextStyle(fontSize: 13)),
          const SizedBox(height: 15),
          SelectTile(
            onPressed: (val) {},
            defaultValue: 'Stable',
            options: [
              'Stable',
              'Beta',
              'Dev',
            ],
          ),
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
                color: Colors.blue,
                onPressed: () {},
                child: const Text(
                  'Continue',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
