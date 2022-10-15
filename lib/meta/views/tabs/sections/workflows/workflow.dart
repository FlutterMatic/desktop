// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/shared_pref.dart';
import 'package:fluttermatic/components/dialog_templates/settings/settings.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/components/widgets/ui/spinner.dart';
import 'package:fluttermatic/core/notifiers/models/state/actions/workflows.dart';
import 'package:fluttermatic/core/notifiers/notifiers/actions/workflows.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/meta/utils/general/shared_pref.dart';
import 'package:fluttermatic/meta/views/tabs/components/bg_loading_indicator.dart';
import 'package:fluttermatic/meta/views/tabs/components/horizontal_axis.dart';
import 'package:fluttermatic/meta/views/tabs/sections/workflows/elements/tile.dart';
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';
import 'package:fluttermatic/meta/views/workflows/startup.dart';

class HomeWorkflowSections extends ConsumerStatefulWidget {
  const HomeWorkflowSections({Key? key}) : super(key: key);

  @override
  _HomeWorkflowSectionsState createState() => _HomeWorkflowSectionsState();
}

class _HomeWorkflowSectionsState extends ConsumerState<HomeWorkflowSections> {
  Future<void> _loadWorkflows([bool force = false]) async {
    WorkflowsState workflowsState = ref.watch(workflowsActionStateNotifier);

    WorkflowsNotifier workflowsNotifier =
        ref.watch(workflowsActionStateNotifier.notifier);

    // Don't load if already loaded from a previous page visit or call unless
    // this is forced.
    if (workflowsNotifier.workflows.isNotEmpty && !force) {
      return;
    }

    await workflowsNotifier.getWorkflows(force);

    if (workflowsState.error && mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        snackBarTile(
          context,
          'Couldn\'t fetch your projects. Please try again.',
          type: SnackBarType.error,
        ),
      );
    }
  }

  Widget _refreshButton() {
    return Row(
      children: <Widget>[
        RectangleButton(
          width: 40,
          height: 40,
          child: const Icon(Icons.refresh_rounded, size: 20),
          onPressed: () => _loadWorkflows(true),
        ),
        HSeparators.small(),
        RectangleButton(
          width: 40,
          height: 40,
          child: const Icon(Icons.add_rounded, size: 20),
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (_) => const StartUpWorkflow(),
            );

            await _loadWorkflows(true);
          },
        ),
      ],
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadWorkflows(false);

      while (
          mounted && SharedPref().pref.getInt(SPConst.projectRefresh) != -1) {
        await Future.delayed(Duration(
            minutes: SharedPref().pref.getInt(SPConst.projectRefresh) ?? 60));

        await _loadWorkflows(true);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        WorkflowsState workflowsState = ref.watch(workflowsActionStateNotifier);

        WorkflowsNotifier workflowsNotifier =
            ref.watch(workflowsActionStateNotifier.notifier);

        return Stack(
          children: <Widget>[
            if (!SharedPref().pref.containsKey(SPConst.projectsPath))
              Center(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(Icons.info_outline_rounded, size: 40),
                      VSeparators.large(),
                      const Text(
                        'You have not yet added the projects path for us to search in. Add the path to continue.',
                        textAlign: TextAlign.center,
                      ),
                      VSeparators.large(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          RectangleButton(
                            width: 200,
                            height: 40,
                            child: const Text('Add Path'),
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (_) => const SettingDialog(
                                    goToPage: SettingsPage.projects),
                              );
                              await _loadWorkflows(true);
                            },
                          ),
                          HSeparators.small(),
                          _refreshButton(),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            else if (workflowsState.loading)
              const Center(child: Spinner(thickness: 2))
            else if (workflowsNotifier.workflows.isEmpty)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.info_outline_rounded, size: 40),
                    VSeparators.large(),
                    const Text(
                      'No workflows found. Check the path you provided or\ncreate a new workflow.',
                      textAlign: TextAlign.center,
                    ),
                    VSeparators.large(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        RectangleButton(
                          width: 200,
                          height: 40,
                          child: const Text('Change Path'),
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (_) => const SettingDialog(
                                goToPage: SettingsPage.projects,
                              ),
                            );
                            await _loadWorkflows(true);
                          },
                        ),
                        HSeparators.small(),
                        _refreshButton(),
                      ],
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(15),
                child: ListView.builder(
                  itemCount: workflowsNotifier.workflows.length,
                  itemBuilder: (_, int i) {
                    bool isLast = i == workflowsNotifier.workflows.length - 1;

                    String name =
                        (workflowsNotifier.workflows[i].projectPath.split('\\')
                              ..removeLast())
                            .last;

                    // Will replace underscores with spaces and then capitalize the
                    // first letter of each word.
                    name = name.replaceAll('_', ' ');
                    name = name.split(' ').map((String s) {
                      return s.substring(0, 1).toUpperCase() +
                          s.substring(1, s.length);
                    }).join(' ');

                    return Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 15),
                      child: HorizontalAxisView(
                        isVertical: true,
                        title:
                            '$name (${workflowsNotifier.workflows[i].workflows.length})',
                        canCollapse: true,
                        action: Row(
                          children: <Widget>[
                            SquareButton(
                              size: 20,
                              tooltip: 'Add Workflow',
                              color: Colors.transparent,
                              hoverColor: Colors.transparent,
                              icon: const Icon(Icons.add_rounded, size: 15),
                              onPressed: () async {
                                await showDialog(
                                  context: context,
                                  builder: (_) => StartUpWorkflow(
                                    pubspecPath:
                                        '${(workflowsNotifier.workflows[i].projectPath.split('\\')..removeLast()).join('\\')}\\pubspec.yaml',
                                  ),
                                );

                                await _loadWorkflows(true);
                              },
                            ),
                            HSeparators.small(),
                            SquareButton(
                              size: 20,
                              tooltip: 'Reload',
                              color: Colors.transparent,
                              hoverColor: Colors.transparent,
                              icon: const Icon(Icons.refresh_rounded, size: 15),
                              onPressed: () => _loadWorkflows(true),
                            ),
                          ],
                        ),
                        content: workflowsNotifier.workflows[i].workflows
                            .map((WorkflowTemplate e) {
                          return WorkflowInfoTile(
                            workflow: e,
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            if (workflowsState.loading &&
                workflowsNotifier.workflows.isNotEmpty)
              const Positioned(
                bottom: 20,
                right: 20,
                child: BgLoadingIndicator('Searching for new workflows...'),
              ),
          ],
        );
      },
    );
  }
}
