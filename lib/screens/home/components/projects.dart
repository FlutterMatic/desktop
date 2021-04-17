import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_installer/components/rectangle_button.dart';
import 'package:flutter_installer/components/round_container.dart';
import 'package:flutter_installer/components/square_button.dart';
import 'package:flutter_installer/components/title_section.dart';
import 'package:flutter_installer/utils/constants.dart';

Widget projects() {
  return SizedBox(
    width: 500,
    child: Column(
      children: <Widget>[
        titleSection('Projects', const Icon(Icons.add_rounded), () {},
            'New Flutter Project'),
        ProjectTile(
          fileName: 'flutter_tooltip',
          lastEdit: 'Jan - 17, 2021',
          //TODO: Show options onPressed
          onOptions: () {},
          //TODO: Open file onPressed
          onPressed: () {},
        ),
        ProjectTile(
          fileName: 'flutter_tooltip',
          lastEdit: 'Jan - 17, 2021',
          //TODO: Show options onPressed
          onOptions: () {},
          //TODO: Open file onPressed
          onPressed: () {},
        ),
        ProjectTile(
          fileName: 'flutter_tooltip',
          lastEdit: 'Jan - 17, 2021',
          //TODO: Show options onPressed
          onOptions: () {},
          //TODO: Open file onPressed
          onPressed: () {},
        ),
      ],
    ),
  );
}

class ProjectTile extends StatefulWidget {
  final String fileName;
  final String? lastEdit;
  final Function() onPressed;
  final Function() onOptions;

  ProjectTile(
      {required this.fileName,
      required this.onPressed,
      required this.onOptions,
      this.lastEdit});

  @override
  _ProjectTileState createState() => _ProjectTileState();
}

bool _hovered = false;

class _ProjectTileState extends State<ProjectTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: MouseRegion(
        onHover: (event) => setState(() => _hovered = true),
        onExit: (event) => setState(() => _hovered = false),
        child: RectangleButton(
          height: 55,
          width: double.infinity,
          onPressed: widget.onPressed,
          child: Row(
            children: <Widget>[
              const Icon(Icons.folder, color: kGreenColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false),
                    widget.lastEdit != null
                        ? Text(
                            widget.lastEdit!,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
              _hovered
                  ? PopupMenuButton(
                      color: kGreyColor,
                      tooltip: 'Options',
                      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                        const PopupMenuItem(
                          child: Text('Open'),
                        ),
                        PopupMenuItem(
                          child: Text(
                            'View in ${Platform.isMacOS ? 'Finder' : 'File Explorer'}',
                          ),
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              const Text('Delete'),
                              const Spacer(),
                              const Icon(Icons.delete, color: kRedColor),
                            ],
                          ),
                        ),
                      ],
                      child: RoundContainer(
                        radius: 5,
                        height: 35,
                        width: 35,
                        padding: EdgeInsets.zero,
                        color: kLightGreyColor,
                        child: const Icon(Icons.more_vert_rounded),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
