import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_template.dart';
import 'package:flutter_installer/components/rectangle_button.dart';
import 'package:flutter_installer/components/square_button.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'dart:io';

class OpenOptionsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Project Options', style: TextStyle(fontSize: 20)),
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
          const SizedBox(height: 20),
          RectangleButton(
            onPressed: () {},
            radius: const BorderRadius.only(
                topLeft: Radius.circular(5), topRight: Radius.circular(5)),
            width: double.infinity,
            child: Row(
              children: [
                const Text('Open'),
                const Spacer(),
                const Icon(Icons.folder_open),
              ],
            ),
          ),
          RectangleButton(
            onPressed: () {},
            radius: BorderRadius.zero,
            width: double.infinity,
            child: Row(
              children: [
                const Text('Open with...'),
                const Spacer(),
                const Icon(Icons.code_rounded),
              ],
            ),
          ),
          RectangleButton(
            onPressed: () {},
            radius: const BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5)),
            width: double.infinity,
            child: Row(
              children: [
                Text(
                    'View in ${Platform.isMacOS ? 'Finder' : 'File Explorer'}'),
                const Spacer(),
                const Icon(Icons.file_present),
              ],
            ),
          ),
          const SizedBox(height: 10),
          RectangleButton(
            onPressed: () {},
            color: kRedColor,
            width: double.infinity,
            child: Row(
              children: [
                const Text('Delete', style: TextStyle(color: Colors.white)),
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
