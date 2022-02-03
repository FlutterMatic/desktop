// 🎯 Dart imports:
import 'dart:isolate';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:path_provider/path_provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/app/constants/shared_pref.dart';
import 'package:fluttermatic/components/dialog_templates/settings/settings.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/components/widgets/ui/spinner.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/bin/utils/workflow.search.dart';
import 'package:fluttermatic/meta/utils/shared_pref.dart';
import 'package:fluttermatic/meta/views/tabs/components/horizontal_axis.dart';
import 'package:fluttermatic/meta/views/tabs/sections/projects/models/projects.services.dart';
import 'package:fluttermatic/meta/views/tabs/sections/workflows/elements/tile.dart';
import 'package:fluttermatic/meta/views/tabs/sections/workflows/models/workflows.services.dart';
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';
import 'package:fluttermatic/meta/views/workflows/startup.dart';

class HomeWorkflowSections extends StatefulWidget {
  const HomeWorkflowSections({Key? key}) : super(key: key);

  @override
  _HomeWorkflowSectionsState createState() => _HomeWorkflowSectionsState();
}

class _HomeWorkflowSectionsState extends State<HomeWorkflowSections> {
  // Utils
  bool _workflowsLoading = true;
  bool _reloadingFromCache = false;
  bool _loadWorkflowsCalled = false;

  // Data
  final List<ProjectWorkflowsGrouped> _workflows = <ProjectWorkflowsGrouped>[];
  final ReceivePort _loadWorkflowsPort =
      ReceivePort('FIND_WORKFLOWS_ISOLATE_PORT');

  Future<void> _loadWorkflows([bool notFirstCall = false]) async {
    try {
      if (SharedPref().pref.containsKey(SPConst.projectsPath)) {
        if (notFirstCall) {
          setState(() => _reloadingFromCache = true);
        }

        await ProjectServicesModel.updateProjectCache(
          cache: ProjectCacheResult(
            projectsPath: SharedPref().pref.getString(SPConst.projectsPath),
            refreshIntervals: null,
            lastProjectReload: null,
            lastWorkflowsReload: null,
          ),
          supportDir: (await getApplicationSupportDirectory()).path,
        );

        Isolate _i = await Isolate.spawn(
          WorkflowServicesModel.getWorkflowsIsolate,
          <dynamic>[
            _loadWorkflowsPort.sendPort,
            (await getApplicationSupportDirectory()).path,
            notFirstCall,
          ],
        ).timeout(const Duration(minutes: 2)).onError((_, StackTrace s) async {
          await logger.file(LogTypeTag.error, 'Failed to get workflows: $_',
              stackTraces: s);

          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            snackBarTile(context, 'Couldn\'t get the workflows.',
                type: SnackBarType.error),
          );

          return Isolate.current;
        });

        if (!_loadWorkflowsCalled) {
          _loadWorkflowsPort.listen((dynamic message) {
            setState(() => _loadWorkflowsCalled = true);
            if (message is List) {
              setState(() {
                _workflowsLoading = false;
                _workflows.clear();
                _workflows.addAll(message.first);
                _reloadingFromCache = message[2] == true;
              });

              // No more expected responses, so will kill the isolate
              if (message[1] == true) {
                _i.kill();
              }
            }
          });
        }
      }
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Couldn\'t load workflows from cache: $_',
          stackTraces: s);
      setState(() {
        _workflowsLoading = false;
        _reloadingFromCache = false;
      });
    }
  }

  Future<void> _refreshMonitor() async {
    if (SharedPref().pref.containsKey(SPConst.projectRefresh) &&
        !_workflowsLoading && // Make sure we are not already reloading from
        // cache or initially fetching.
        !_reloadingFromCache) {
      while (mounted) {
        await Future<void>.delayed(Duration(
            minutes: SharedPref().pref.getInt(SPConst.projectRefresh) ?? 1));
        await _loadWorkflows(true);
        await logger.file(
            LogTypeTag.info, 'Reloaded workflows tab on project interval.');
      }
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
    _loadWorkflows();
    _refreshMonitor();
    super.initState();
  }

  @override
  void dispose() {
    _loadWorkflowsPort.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        else if (_workflowsLoading)
          const Center(child: Spinner(thickness: 2))
        else if (_workflows.isEmpty)
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
              itemCount: _workflows.length,
              itemBuilder: (_, int i) {
                bool _isLast = i == _workflows.length - 1;

                String _name = _workflows[i].path.split('\\').last;

                // Will replace underscores with spaces and then capitalize the
                // first letter of each word.
                _name = _name.replaceAll('_', ' ');
                _name = _name.split(' ').map((String s) {
                  return s.substring(0, 1).toUpperCase() +
                      s.substring(1, s.length);
                }).join(' ');

                return Padding(
                  padding: EdgeInsets.only(bottom: _isLast ? 0 : 15),
                  child: HorizontalAxisView(
                    isVertical: true,
                    title: _name + ' (${_workflows[i].workflows.length})',
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
                                  pubspecPath: _workflows[i].path),
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
                    content: _workflows[i].workflows.map((WorkflowTemplate e) {
                      return WorkflowInfoTile(
                        workflow: e,
                        path: _workflows[i].path +
                            '\\$fmWorkflowDir\\' +
                            e.name +
                            '.json',
                        onDelete: () {
                          setState(() => _workflows[i].workflows.remove(e));
                          if (_workflows[i].workflows.isEmpty) {
                            setState(() => _workflows.removeAt(i));
                          }
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        if (_reloadingFromCache)
          Positioned(
            bottom: 20,
            right: 20,
            child: Tooltip(
              message: 'Searching for new workflows...',
              child: RoundContainer(
                borderWith: 2,
                borderColor: Colors.blueGrey.withOpacity(0.5),
                child: const Spinner(thickness: 2),
                height: 40,
                width: 40,
                radius: 60,
              ),
            ),
          ),
      ],
    );
  }
}
