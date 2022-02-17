// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/stage_tile.dart';
import 'package:fluttermatic/meta/utils/bin/utils/workflow.search.dart';
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';
import 'package:fluttermatic/meta/views/workflows/runner/runner.dart';
import 'package:fluttermatic/meta/views/workflows/views/options.dart';

class SearchWorkflowsTile extends StatelessWidget {
  final ProjectWorkflowsGrouped workflow;

  const SearchWorkflowsTile({
    Key? key,
    required this.workflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                    workflow.path.split('\\').last.split('_').map((String e) {
                      // Capitalize first letter
                      return e.substring(0, 1).toUpperCase() + e.substring(1);
                    }).join(' '),
                    style: const TextStyle(fontSize: 18)),
              ),
              const StageTile(stageType: StageType.prerelease),
            ],
          ),
        ),
        VSeparators.small(),
        SizedBox(
          height: 150,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: workflow.workflows.length,
            itemBuilder: (_, int i) {
              return _WorkflowTile(
                  path: workflow.path, workflow: workflow.workflows[i]);
            },
          ),
        ),
      ],
    );
  }
}

class _WorkflowTile extends StatelessWidget {
  final String path;
  final WorkflowTemplate workflow;

  const _WorkflowTile({
    Key? key,
    required this.workflow,
    required this.path,
  }) : super(key: key);

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
            Text(workflow.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            VSeparators.xSmall(),
            Expanded(
              child: Text(
                workflow.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            VSeparators.xSmall(),
            Row(
              children: <Widget>[
                SquareButton(
                  size: 20,
                  tooltip: 'Options',
                  color: Colors.transparent,
                  hoverColor: Colors.transparent,
                  icon: const Icon(Icons.more_vert_rounded, size: 12),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => ShowWorkflowTileOptions(
                        workflowPath: path +
                            '\\' +
                            fmWorkflowDir +
                            '\\' +
                            workflow.name +
                            '.json',
                        onDelete: () {},
                        onReload: () {},
                      ),
                    );
                  },
                ),
                const Spacer(),
                SquareButton(
                  size: 20,
                  tooltip: 'Run',
                  color: Colors.transparent,
                  hoverColor: Colors.transparent,
                  icon: const Icon(Icons.play_arrow_rounded,
                      size: 12, color: kGreenColor),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => WorkflowRunnerDialog(
                          workflowPath: path +
                              '\\' +
                              fmWorkflowDir +
                              '\\' +
                              workflow.name +
                              '.json'),
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
