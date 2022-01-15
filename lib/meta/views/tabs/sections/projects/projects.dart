// 🎯 Dart imports:
import 'dart:isolate';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/shared_pref.dart';
import 'package:manager/components/dialog_templates/settings/settings.dart';
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/core/libraries/models.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/core/libraries/utils.dart';
import 'package:manager/core/libraries/views.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/meta/views/dialogs/open_project.dart';
import 'package:manager/meta/views/tabs/sections/projects/models/projects.services.dart';
import 'package:manager/meta/views/workflows/views/existing_workflows.dart';

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
  final ReceivePort _loadProjectsPort = ReceivePort('find_projects_isolate');

  Future<void> _loadProjects([bool notFirstCall = false]) async {
    try {
      if (SharedPref().pref.containsKey(SPConst.projectsPath)) {
        if (notFirstCall) {
          setState(() => _reloadingFromCache = true);
        }

        Isolate _isolate = await Isolate.spawn(
          ProjectServicesModel.getProjectsIsolate,
          _loadProjectsPort.sendPort,
        ).timeout(const Duration(minutes: 2));

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
      await logger.file(LogTypeTag.error, 'Couldn\'t load projects from cache',
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
          PageRouteBuilder<Route<dynamic>>(
            pageBuilder: (_, __, ___) => const HomeScreen(index: 1),
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
                              goToPage: 'Projects',
                            ),
                          );
                          await Navigator.pushReplacement(
                            context,
                            PageRouteBuilder<Route<dynamic>>(
                              pageBuilder: (_, __, ___) =>
                                  const HomeScreen(index: 1),
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
                            goToPage: 'Projects',
                          ),
                        );
                        await Navigator.pushReplacement(
                          context,
                          PageRouteBuilder<Route<dynamic>>(
                            pageBuilder: (_, __, ___) =>
                                const HomeScreen(index: 1),
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
                content: _projects.map((ProjectObject e) {
                  return RoundContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          e.name,
                          style: const TextStyle(fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                        VSeparators.normal(),
                        Expanded(
                          child: Text(
                            e.description ?? 'No project description found.',
                            style: const TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        VSeparators.normal(),
                        Text(
                          'Modified date: ${toMonth(e.modDate.month)} ${e.modDate.day}, ${e.modDate.year}',
                          maxLines: 2,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        VSeparators.normal(),
                        Tooltip(
                          waitDuration: const Duration(milliseconds: 500),
                          message: e.path,
                          child: Text(
                            e.path,
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
                                    builder: (_) =>
                                        OpenProjectOnEditor(path: e.path),
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
                              child: const Icon(Icons.play_arrow_rounded,
                                  color: kGreenColor),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => ShowExistingWorkflows(
                                      pubspecPath: e.path),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        if (_reloadingFromCache)
          const Positioned(
            bottom: 20,
            right: 20,
            child: Tooltip(
              message: 'Searching for new projects...',
              child: RoundContainer(
                height: 40,
                width: 40,
                radius: 60,
                child: Spinner(thickness: 2),
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
