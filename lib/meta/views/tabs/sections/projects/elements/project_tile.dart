// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/core/libraries/views.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/meta/views/dialogs/open_project.dart';
import 'package:manager/meta/views/workflows/views/existing_workflows.dart';

class ProjectInfoTile extends StatefulWidget {
  final String name;
  final String? description;
  final DateTime modDate;
  final String path;

  const ProjectInfoTile({
    Key? key,
    required this.name,
    required this.description,
    required this.modDate,
    required this.path,
  }) : super(key: key);

  @override
  State<ProjectInfoTile> createState() => _ProjectInfoTileState();
}

class _ProjectInfoTileState extends State<ProjectInfoTile> {
  bool _isHovering = true;
  @override
  Widget build(BuildContext context) {
    return RoundContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.name,
            style: const TextStyle(fontSize: 18),
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          VSeparators.normal(),
          Expanded(
            child: Text(
              widget.description ?? 'No project description found.',
              style: const TextStyle(color: Colors.grey),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
          VSeparators.normal(),
          Text(
            'Modified date: ${toMonth(widget.modDate.month)} ${widget.modDate.day}, ${widget.modDate.year}',
            maxLines: 2,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: TextStyle(color: Colors.grey[700]),
          ),
          VSeparators.normal(),
          Tooltip(
            waitDuration: const Duration(milliseconds: 500),
            message: widget.path,
            child: Text(
              widget.path,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          VSeparators.normal(),
          Row(
            children: <Widget>[
              Expanded(
                child: RectangleButton(
                  child: const Text('Open Project'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => OpenProjectOnEditor(path: widget.path),
                    );
                  },
                ),
              ),
              HSeparators.xSmall(),
              HSeparators.xSmall(),
              RectangleButton(
                width: 40,
                height: 40,
                padding: EdgeInsets.zero,
                child: const Icon(Icons.play_arrow_rounded, color: kGreenColor),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) =>
                        ShowExistingWorkflows(pubspecPath: widget.path),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
