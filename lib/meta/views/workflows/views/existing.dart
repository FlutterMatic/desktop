// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/components/widgets/ui/spinner.dart';
import 'package:fluttermatic/core/notifiers/models/state/actions/workflows.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/search.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';
import 'package:fluttermatic/meta/views/workflows/runner/runner.dart';
import 'package:fluttermatic/meta/views/workflows/startup.dart';
import 'package:fluttermatic/meta/views/workflows/views/options.dart';

class ShowExistingWorkflows extends ConsumerStatefulWidget {
  final String pubspecPath;

  const ShowExistingWorkflows({
    Key? key,
    required this.pubspecPath,
  }) : super(key: key);

  @override
  _ShowExistingWorkflowsState createState() => _ShowExistingWorkflowsState();
}

class _ShowExistingWorkflowsState extends ConsumerState<ShowExistingWorkflows> {
  late List<WorkflowTemplate> workflows = ref
      .watch(workflowsActionStateNotifier.notifier)
      .workflows
      .firstWhere(
          (e) => e.projectPath.startsWith(
              (widget.pubspecPath.split('\\')..removeLast()).join('\\')),
          orElse: () => ProjectWorkflowsGrouped(projectPath: '', workflows: []))
      .workflows;

  Future<void> _initProjectWorkflows() async {
    try {
      if (workflows.isEmpty) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          snackBarTile(
            context,
            'Create your first workflow for this project.',
          ),
        );

        Navigator.pop(context);

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => StartUpWorkflow(pubspecPath: widget.pubspecPath),
        );

        return;
      }
    } catch (e, s) {
      await logger.file(LogTypeTag.error,
          'Couldn\'t load workflows for project at pubspec path: ${widget.pubspecPath}',
          stackTrace: s);

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          snackBarTile(
            context,
            'Failed to load workflows. Something went wrong when we tried to load the workflows for this project. Files may be missing or corrupted.',
            type: SnackBarType.error,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initProjectWorkflows();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        WorkflowsState workflowsState = ref.watch(workflowsActionStateNotifier);

        return DialogTemplate(
          child: Column(
            children: <Widget>[
              const DialogHeader(title: 'Workflows'),
              if (workflowsState.loading)
                const Padding(
                  padding: EdgeInsets.all(15),
                  child: Spinner(size: 20, thickness: 2),
                )
              else if (workflowsState.error)
                informationWidget(
                  'Failed to load workflows. Something went wrong when we tried to load the workflows for this project. Files may be missing or corrupted.',
                  type: InformationType.error,
                )
              else if (workflows.isEmpty)
                informationWidget(
                  'There are no workflows for this project. Create your first workflow for this project.',
                  type: InformationType.info,
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 380),
                  child: ListView.builder(
                    itemCount: workflows.length,
                    shrinkWrap: true,
                    itemBuilder: (_, int i) {
                      bool isLast = i == workflows.length - 1;

                      return Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 5),
                        child: _WorkflowTile(
                          template: workflows[i],
                        ),
                      );
                    },
                  ),
                ),
              VSeparators.normal(),
              if (!workflowsState.loading)
                Row(
                  children: <Widget>[
                    Expanded(
                      child: RectangleButton(
                        child: const Text('Close'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    HSeparators.normal(),
                    Expanded(
                      child: RectangleButton(
                        child: const Text('New Workflow'),
                        onPressed: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => StartUpWorkflow(
                                pubspecPath: widget.pubspecPath),
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _WorkflowTile extends StatefulWidget {
  final WorkflowTemplate template;

  const _WorkflowTile({
    Key? key,
    required this.template,
  }) : super(key: key);

  @override
  __WorkflowTileState createState() => __WorkflowTileState();
}

class __WorkflowTileState extends State<_WorkflowTile> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (_) => setState(() => _isHovering = true),
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: RoundContainer(
        padding: EdgeInsets.zero,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(widget.template.name, maxLines: 1),
              ),
            ),
            HSeparators.normal(),
            if (!widget.template.isSaved)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Tooltip(
                  padding: const EdgeInsets.all(5),
                  message:
                      '''
This workflow is not completed yet. You can edit it, 
but you will need to save it before you can run it.''',
                  child: SvgPicture.asset(Assets.warn, height: 20),
                ),
              ),
            if (_isHovering)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Tooltip(
                        message: 'Options',
                        waitDuration: const Duration(seconds: 1),
                        child: RectangleButton(
                          width: 30,
                          height: 30,
                          padding: const EdgeInsets.all(2),
                          child: const Icon(Icons.more_vert_rounded, size: 12),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => ShowWorkflowTileOptions(
                                workflow: widget.template,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (widget.template.isSaved)
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Tooltip(
                          message: 'Run',
                          waitDuration: const Duration(seconds: 1),
                          child: RectangleButton(
                            width: 30,
                            height: 30,
                            padding: const EdgeInsets.all(2),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              size: 12,
                              color: kGreenColor,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (_) => WorkflowRunnerDialog(
                                    workflow: widget.template),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
