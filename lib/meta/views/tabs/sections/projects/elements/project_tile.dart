// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/core/libraries/views.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/meta/views/dialogs/open_project.dart';
import 'package:manager/meta/views/workflows/views/existing_workflows.dart';

class ProjectInfoTile extends StatelessWidget {
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

  // TODO: Show top right menu on hover to delete, and other project options.

  @override
  Widget build(BuildContext context) {
    return RoundContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            name,
            style: const TextStyle(fontSize: 18),
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          VSeparators.normal(),
          Expanded(
            child: Text(
              description ?? 'No project description found.',
              style: const TextStyle(color: Colors.grey),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
          VSeparators.normal(),
          Text(
            'Modified date: ${toMonth(modDate.month)} ${modDate.day}, ${modDate.year}',
            maxLines: 2,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: TextStyle(color: Colors.grey[700]),
          ),
          VSeparators.normal(),
          Tooltip(
            waitDuration: const Duration(milliseconds: 500),
            message: path,
            child: Text(
              path,
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
                      builder: (_) => OpenProjectOnEditor(path: path),
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
                    builder: (_) => ShowExistingWorkflows(pubspecPath: path),
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
