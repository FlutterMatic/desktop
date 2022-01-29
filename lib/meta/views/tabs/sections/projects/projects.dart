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
import 'package:fluttermatic/core/models/projects.model.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/shared_pref.dart';
import 'package:fluttermatic/meta/views/tabs/components/horizontal_axis.dart';
import 'package:fluttermatic/meta/views/tabs/home.dart';
import 'package:fluttermatic/meta/views/tabs/sections/projects/elements/project_tile.dart';
import 'package:fluttermatic/meta/views/tabs/sections/projects/models/projects.services.dart';

class HomeProjectsSection extends StatefulWidget {
  const HomeProjectsSection({Key? key}) : super(key: key);

  @override
  _HomeProjectsSectionState createState() => _HomeProjectsSectionState();
}

class _HomeProjectsSectionState extends State<HomeProjectsSection> {
  // Utils
  bool _projectsLoading = true;
  bool _reloadingFromCache = false;
  bool _loadProjectsCalled = false;

  // Data
  final List<ProjectObject> _projects = <ProjectObject>[];
  final ReceivePort _loadProjectsPort =
      ReceivePort('FIND_PROJECTS_ISOLATE_PORT');

  Future<void> _loadProjects([bool notFirstCall = false]) async {
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

        Isolate _isolate = await Isolate.spawn(
          ProjectServicesModel.getProjectsIsolate,
          <dynamic>[
            _loadProjectsPort.sendPort,
            (await getApplicationSupportDirectory()).path,
            notFirstCall,
          ],
        ).timeout(const Duration(minutes: 2)).onError((_, StackTrace s) async {
          await logger.file(LogTypeTag.error, 'Failed to get projects: $_',
              stackTraces: s);

          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            snackBarTile(context, 'Couldn\'t get the projects.',
                type: SnackBarType.error),
          );

          return Isolate.current;
        });

        if (!_loadProjectsCalled) {
          _loadProjectsPort.listen((dynamic message) {
            setState(() => _loadProjectsCalled = true);
            if (message is List) {
              setState(() {
                _projectsLoading = false;
                _projects.clear();
                _projects.addAll(message.first);
                if (message[2] == true) {
                  _reloadingFromCache = true;
                } else {
                  _reloadingFromCache = false;
                }
              });
              if (message[1] == true) {
                _isolate.kill();
              }
            }
          });
        }
      }
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Couldn\'t load projects from cache: $_',
          stackTraces: s);
      setState(() {
        _projectsLoading = false;
        _reloadingFromCache = false;
      });
    }
  }

  Future<void> _refreshMonitor() async {
    if (SharedPref().pref.containsKey(SPConst.projectRefresh) &&
        !_projectsLoading && // Make sure we are not already reloading from
        // cache or initially fetching.
        !_reloadingFromCache) {
      while (mounted) {
        await Future<void>.delayed(Duration(
            minutes: SharedPref().pref.getInt(SPConst.projectRefresh) ?? 1));
        await _loadProjects(true);
        await logger.file(
            LogTypeTag.info, 'Reloaded project tab on project interval.');
      }
    }
  }

  Widget _refreshButton() {
    return RectangleButton(
      width: 40,
      height: 40,
      child: const Icon(Icons.refresh_rounded, size: 20),
      onPressed: () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder<Widget>(
            pageBuilder: (_, __, ___) =>
                const HomeScreen(tab: HomeTab.projects),
            transitionDuration: Duration.zero,
          ),
        );
      },
    );
  }

  @override
  void initState() {
    _loadProjects();
    _refreshMonitor();
    super.initState();
  }

  @override
  void dispose() {
    _loadProjectsPort.close();
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
                              goToPage: SettingsPage.projects,
                            ),
                          );
                          await Navigator.pushReplacement(
                            context,
                            PageRouteBuilder<Route<dynamic>>(
                              pageBuilder: (_, __, ___) =>
                                  const HomeScreen(tab: HomeTab.projects),
                              transitionDuration: Duration.zero,
                            ),
                          );
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
        else if (_projectsLoading)
          const Center(child: Spinner(thickness: 2))
        else if (_projects.isEmpty)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.info_outline_rounded, size: 40),
                VSeparators.large(),
                const Text(
                  'No projects found. Please check the path you have added.',
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
                        await Navigator.pushReplacement(
                          context,
                          PageRouteBuilder<Route<dynamic>>(
                            pageBuilder: (_, __, ___) =>
                                const HomeScreen(tab: HomeTab.projects),
                            transitionDuration: Duration.zero,
                          ),
                        );
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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: HorizontalAxisView(
                title: 'Projects',
                isVertical: true,
                action: SquareButton(
                  size: 20,
                  tooltip: 'Reload',
                  color: Colors.transparent,
                  hoverColor: Colors.transparent,
                  icon: const Icon(Icons.refresh_rounded, size: 15),
                  onPressed: () => _loadProjects(true),
                ),
                content: _projects.map((ProjectObject e) {
                  return ProjectInfoTile(
                    name: e.name,
                    description: e.description,
                    modDate: e.modDate,
                    path: e.path,
                  );
                }).toList(),
              ),
            ),
          ),
        if (_reloadingFromCache)
          Positioned(
            bottom: 20,
            right: 20,
            child: Tooltip(
              message: 'Searching for new projects...',
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

String toMonth(int month) {
  switch (month) {
    case 1:
      return 'Jan';
    case 2:
      return 'Feb';
    case 3:
      return 'Mar';
    case 4:
      return 'Apr';
    case 5:
      return 'May';
    case 6:
      return 'June';
    case 7:
      return 'July';
    case 8:
      return 'Aug';
    case 9:
      return 'Sept';
    case 10:
      return 'Oct';
    case 11:
      return 'Nov';
    case 12:
      return 'Dec';
    default:
      return 'err';
  }
}
