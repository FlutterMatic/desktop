import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/new_project.dart';
import 'package:flutter_installer/components/dialog_templates/open_options.dart';
import 'package:flutter_installer/components/rectangle_button.dart';
import 'package:flutter_installer/components/square_button.dart';
import 'package:flutter_installer/components/title_section.dart';
import 'package:flutter_installer/utils/constants.dart';

Widget projects(BuildContext context) {
  return SizedBox(
    width: 500,
    child: Column(
      children: <Widget>[
        titleSection(
            'Projects',
            const Icon(Icons.add_rounded),
            () => showDialog(
                  context: context,
                  builder: (_) => NewProjectDialog(),
                ),
            'New Flutter Project'),
        ProjectTile(
          fileName: 'flutter_tooltip',
          lastEdit: 'Jan - 17, 2021',
          //TODO: Open file onPressed
          onPressed: () {},
        ),
        ProjectTile(
          fileName: 'flutter_tooltip',
          lastEdit: 'Jan - 17, 2021',
          //TODO: Open file onPressed
          onPressed: () {},
        ),
        ProjectTile(
          fileName: 'flutter_tooltip',
          lastEdit: 'Jan - 17, 2021',
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

  ProjectTile({
    required this.fileName,
    required this.onPressed,
    this.lastEdit,
  });

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
        onEnter: (event) => setState(() => _hovered = false),
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
                  ? SquareButton(
                      tooltip: 'Options',
                      padding: const EdgeInsets.all(5),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => OpenOptionsDialog(),
                        );
                      },
                      icon: const Icon(Icons.more_vert_rounded),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
