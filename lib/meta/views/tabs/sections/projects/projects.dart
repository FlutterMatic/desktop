// 🎯 Dart imports:
import 'dart:io';
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
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/components/widgets/ui/spinner.dart';
import 'package:fluttermatic/core/models/projects.model.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/extract_pubspec.dart';
import 'package:fluttermatic/meta/utils/shared_pref.dart';
import 'package:fluttermatic/meta/views/tabs/components/bg_loading_indicator.dart';
import 'package:fluttermatic/meta/views/tabs/components/horizontal_axis.dart';
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
  final List<ProjectObject> _dartProjects = <ProjectObject>[];
  final List<ProjectObject> _pinnedProjects = <ProjectObject>[];
  final List<ProjectObject> _flutterProjects = <ProjectObject>[];
  final ReceivePort _loadProjectsPort =
      ReceivePort('FIND_PROJECTS_ISOLATE_PORT');

  Future<void> _loadProjects([bool notFirstCall = false]) async {
    try {
      if (SharedPref().pref.containsKey(SPConst.projectsPath)) {
        if (notFirstCall && mounted) {
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
            if (mounted) {
              setState(() => _loadProjectsCalled = true);
            }
            if (message is List && mounted) {
              setState(() {
                _projectsLoading = false;

                // Clear the existing list of projects before adding the newly
                // loaded ones.
                _pinnedProjects.clear();
                _flutterProjects.clear();
                _dartProjects.clear();

                // Adds the pinned projects
                _pinnedProjects.addAll(
                    (message.first as ProjectIsolateFetchResult)
                        .pinnedProjects);

                // Will sort the Dart and Flutter projects.
                List<ProjectObject> _dart = <ProjectObject>[];
                List<ProjectObject> _flutter = <ProjectObject>[];

                // Sort
                for (ProjectObject project
                    in (message.first as ProjectIsolateFetchResult).projects) {
                  try {
                    PubspecInfo _pubspec = extractPubspec(
                        lines: File(project.path + '\\pubspec.yaml')
                            .readAsLinesSync(),
                        path: project.path + '\\pubspec.yaml');

                    if (_pubspec.isFlutterProject) {
                      _flutter.add(project);
                    } else {
                      _dart.add(project);
                    }
                  } catch (_, s) {
                    logger.file(LogTypeTag.warning,
                        'Failed to sort in project tabs projects. Ignoring Project: $_',
                        stackTraces: s);
                  }
                }

                // Add
                _dartProjects.addAll(_dart);
                _flutterProjects.addAll(_flutter);

                _reloadingFromCache = message[2] == true;
              });

              if (message[1] == true) {
                _i.kill();
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
    while (mounted) {
      await Future<void>.delayed(Duration(
          minutes: SharedPref().pref.getInt(SPConst.projectRefresh) ?? 1));
      if (!_projectsLoading) {
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
      onPressed: () => _loadProjects(true),
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
      fit: StackFit.expand,
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
                          await _loadProjects(true);
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
        else if (_pinnedProjects.isEmpty &&
            _flutterProjects.isEmpty &&
            _dartProjects.isEmpty)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.info_outline_rounded, size: 40),
                VSeparators.large(),
                const Text(
                  'No projects found. Please check the path you\nhave added.',
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
                        await _loadProjects(true);
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
              child: Column(
                children: <Widget>[
                  if (_pinnedProjects.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: HorizontalAxisView(
                        title: 'Pinned Projects',
                        isVertical: true,
                        canCollapse: true,
                        isCollapsedInitially: SharedPref()
                                .pref
                                .getBool(SPConst.pinnedProjectsCollapsed) ??
                            false,
                        onCollapse: (bool isCollapsed) {
                          SharedPref().pref.setBool(
                              SPConst.pinnedProjectsCollapsed, isCollapsed);
                        },
                        action: SquareButton(
                          size: 20,
                          tooltip: 'Reload',
                          color: Colors.transparent,
                          hoverColor: Colors.transparent,
                          icon: const Icon(Icons.refresh_rounded, size: 15),
                          onPressed: () => _loadProjects(true),
                        ),
                        content: _pinnedProjects.map((ProjectObject e) {
                          return ProjectInfoTile(
                            project: e,
                            onPinChanged: () {
                              // Get the information about this project whether
                              // it is Flutter or Dart so we can add it to the
                              // correct list.
                              PubspecInfo _pubspec = extractPubspec(
                                  lines: File(e.path + '\\pubspec.yaml')
                                      .readAsLinesSync(),
                                  path: e.path + '\\pubspec.yaml');

                              // Remove it from the pinned list and add it to
                              // the Flutter list.
                              ProjectObject _project = ProjectObject(
                                name: e.name,
                                modDate: e.modDate,
                                path: e.path,
                                description: e.description,
                                pinned: false,
                              );

                              setState(() {
                                _pinnedProjects.remove(e);

                                if (_pubspec.isFlutterProject) {
                                  _flutterProjects.add(_project);
                                } else {
                                  _dartProjects.add(_project);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  if (_flutterProjects.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: HorizontalAxisView(
                        title: 'Flutter Projects',
                        isVertical: true,
                        canCollapse: true,
                        isCollapsedInitially: SharedPref()
                                .pref
                                .getBool(SPConst.flutterProjectsCollapsed) ??
                            false,
                        onCollapse: (bool isCollapsed) {
                          SharedPref().pref.setBool(
                              SPConst.flutterProjectsCollapsed, isCollapsed);
                        },
                        action: SquareButton(
                          size: 20,
                          tooltip: 'Reload',
                          color: Colors.transparent,
                          hoverColor: Colors.transparent,
                          icon: const Icon(Icons.refresh_rounded, size: 15),
                          onPressed: () => _loadProjects(true),
                        ),
                        content: _flutterProjects.map((ProjectObject e) {
                          return ProjectInfoTile(
                            project: e,
                            onPinChanged: () {
                              // Remove it from the flutter projects list and
                              // add it to the pinned list.
                              ProjectObject _project = ProjectObject(
                                name: e.name,
                                modDate: e.modDate,
                                path: e.path,
                                description: e.description,
                                pinned: true,
                              );

                              setState(() {
                                _flutterProjects.remove(e);
                                _pinnedProjects.add(_project);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  if (_dartProjects.isNotEmpty)
                    HorizontalAxisView(
                      title: 'Dart Projects',
                      canCollapse: true,
                      isVertical: true,
                      isCollapsedInitially: SharedPref()
                              .pref
                              .getBool(SPConst.dartProjectsCollapsed) ??
                          false,
                      onCollapse: (bool isCollapsed) {
                        SharedPref().pref.setBool(
                            SPConst.dartProjectsCollapsed, isCollapsed);
                      },
                      action: SquareButton(
                        size: 20,
                        tooltip: 'Reload',
                        color: Colors.transparent,
                        hoverColor: Colors.transparent,
                        icon: const Icon(Icons.refresh_rounded, size: 15),
                        onPressed: () => _loadProjects(true),
                      ),
                      content: _dartProjects.map((ProjectObject e) {
                        return ProjectInfoTile(
                          project: e,
                          onPinChanged: () {
                            // Remove it from the flutter projects list and
                            // add it to the pinned list.
                            ProjectObject _project = ProjectObject(
                              name: e.name,
                              modDate: e.modDate,
                              path: e.path,
                              description: e.description,
                              pinned: true,
                            );

                            setState(() {
                              _dartProjects.remove(e);
                              _pinnedProjects.add(_project);
                            });
                          },
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        if (_reloadingFromCache)
          const Positioned(
            bottom: 20,
            right: 20,
            child: BgLoadingIndicator('Searching for new projects...'),
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
