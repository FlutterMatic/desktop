import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_template.dart';
import 'package:flutter_installer/components/rectangle_button.dart';
import 'package:flutter_installer/components/square_button.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'dart:io';

class OpenOptionsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Project Options',
                style: TextStyle(fontSize: 20),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: SquareButton(
                  icon: const Icon(Icons.close_rounded),
                  color: customTheme.buttonColor,
                  hoverColor: customTheme.errorColor,
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          RectangleButton(
            onPressed: () {},
            color: Colors.blueGrey.withOpacity(0.2),
            hoverColor: Colors.blueGrey.withOpacity(0.3),
            radius: const BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
            ),
            width: double.infinity,
            child: Row(
              children: [
                Text(
                  'Open',
                  style:
                      TextStyle(color: customTheme.textTheme.bodyText1!.color),
                ),
                const Spacer(),
                Icon(
                  Icons.folder_open,
                  color:
                      customTheme.textTheme.bodyText1!.color!.withOpacity(0.4),
                ),
              ],
            ),
          ),
          RectangleButton(
            onPressed: () {},
            color: Colors.blueGrey.withOpacity(0.2),
            hoverColor: Colors.blueGrey.withOpacity(0.3),
            radius: BorderRadius.zero,
            width: double.infinity,
            child: Row(
              children: [
                Text(
                  'Open with...',
                  style:
                      TextStyle(color: customTheme.textTheme.bodyText1!.color),
                ),
                const Spacer(),
                Icon(
                  Icons.code_rounded,
                  color:
                      customTheme.textTheme.bodyText1!.color!.withOpacity(0.4),
                ),
              ],
            ),
          ),
          RectangleButton(
            onPressed: () {},
            color: Colors.blueGrey.withOpacity(0.2),
            hoverColor: Colors.blueGrey.withOpacity(0.3),
            radius: const BorderRadius.only(
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(5),
            ),
            width: double.infinity,
            child: Row(
              children: [
                Text(
                  'View in ${Platform.isMacOS ? 'Finder' : 'File Explorer'}',
                  style:
                      TextStyle(color: customTheme.textTheme.bodyText1!.color),
                ),
                const Spacer(),
                Icon(
                  Icons.file_present,
                  color:
                      customTheme.textTheme.bodyText1!.color!.withOpacity(0.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          RectangleButton(
            onPressed: () {},
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            color: kRedColor,
            hoverColor: Colors.red,
            width: double.infinity,
            child: Row(
              children: [
                const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
                const Spacer(),
                const Icon(Icons.delete_forever_outlined, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
