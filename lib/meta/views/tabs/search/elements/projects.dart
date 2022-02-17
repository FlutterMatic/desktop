// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/core/models/projects.model.dart';
import 'package:fluttermatic/meta/views/dialogs/open_project.dart';
import 'package:fluttermatic/meta/views/tabs/sections/projects/dialogs/project_options.dart';

class SearchProjectTile extends StatelessWidget {
  final ProjectObject project;

  const SearchProjectTile({Key? key, required this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 5, left: 10),
      child: RoundContainer(
        height: 150,
        width: 200,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(project.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            VSeparators.xSmall(),
            Expanded(
              child: Text(
                project.description ?? 'No description found',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            VSeparators.xSmall(),
            Row(
              children: <Widget>[
                InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => OpenProjectInEditor(path: project.path),
                      );
                    },
                    child: const Text('Open')),
                const Spacer(),
                SquareButton(
                  size: 20,
                  tooltip: 'Options',
                  color: Colors.transparent,
                  hoverColor: Colors.transparent,
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => ProjectOptionsDialog(path: project.path),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
