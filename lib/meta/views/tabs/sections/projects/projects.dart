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
import 'package:fluttermatic/core/models/projects.dart';
import 'package:fluttermatic/core/notifiers/models/state/actions/projects.dart';
import 'package:fluttermatic/core/notifiers/notifiers/actions/projects.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/meta/utils/general/shared_pref.dart';
import 'package:fluttermatic/meta/views/tabs/components/bg_loading_indicator.dart';
import 'package:fluttermatic/meta/views/tabs/components/horizontal_axis.dart';
import 'package:fluttermatic/meta/views/tabs/sections/projects/elements/project_tile.dart';

class HomeProjectsSection extends ConsumerStatefulWidget {
  const HomeProjectsSection({Key? key}) : super(key: key);

  @override
  _HomeProjectsSectionState createState() => _HomeProjectsSectionState();
}

class _HomeProjectsSectionState extends ConsumerState<HomeProjectsSection> {
  Future<void> _loadProjects([bool force = false]) async {
    ProjectsState projectsState = ref.watch(projectsActionStateNotifier);

    ProjectsNotifier projectsNotifier =
        ref.watch(projectsActionStateNotifier.notifier);

    // Don't load if already loaded from a previous page visit or call.
    if ([
      ...projectsNotifier.pinned,
      ...projectsNotifier.flutter,
      ...projectsNotifier.dart
    ].isNotEmpty) {
      return;
    }

    await projectsNotifier.getProjectsWithIsolate(force);

    if (projectsState.isError && mounted) {
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
    return RectangleButton(
      width: 40,
      height: 40,
      onPressed: () => _loadProjects(true),
      child: const Icon(Icons.refresh_rounded, size: 20),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProjects(false));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        ProjectsState projectsState = ref.watch(projectsActionStateNotifier);

        ProjectsNotifier projectsNotifier =
            ref.watch(projectsActionStateNotifier.notifier);

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
            else if (projectsState.isLoading &&
                [
                  ...projectsNotifier.pinned,
                  ...projectsNotifier.flutter,
                  ...projectsNotifier.dart,
                ].isEmpty)
              const Center(child: Spinner(thickness: 2))
            else if ([
              ...projectsNotifier.pinned,
              ...projectsNotifier.flutter,
              ...projectsNotifier.dart,
            ].isEmpty)
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
                      if (projectsNotifier.pinned.isNotEmpty)
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
                            content:
                                projectsNotifier.pinned.map((ProjectObject e) {
                              return ProjectInfoTile(project: e);
                            }).toList(),
                          ),
                        ),
                      if (projectsNotifier.flutter.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: HorizontalAxisView(
                            title: 'Flutter Projects',
                            isVertical: true,
                            canCollapse: true,
                            isCollapsedInitially: SharedPref().pref.getBool(
                                    SPConst.flutterProjectsCollapsed) ??
                                false,
                            onCollapse: (bool isCollapsed) {
                              SharedPref().pref.setBool(
                                  SPConst.flutterProjectsCollapsed,
                                  isCollapsed);
                            },
                            action: SquareButton(
                              size: 20,
                              tooltip: 'Reload',
                              color: Colors.transparent,
                              hoverColor: Colors.transparent,
                              icon: const Icon(Icons.refresh_rounded, size: 15),
                              onPressed: () => _loadProjects(true),
                            ),
                            content:
                                projectsNotifier.flutter.map((ProjectObject e) {
                              return ProjectInfoTile(project: e);
                            }).toList(),
                          ),
                        ),
                      if (projectsNotifier.dart.isNotEmpty)
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
                          content: projectsNotifier.dart.map((ProjectObject e) {
                            return ProjectInfoTile(project: e);
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            if (projectsState.isLoading &&
                [
                  ...projectsNotifier.pinned,
                  ...projectsNotifier.flutter,
                  ...projectsNotifier.dart,
                ].isNotEmpty)
              const Positioned(
                bottom: 20,
                right: 20,
                child: BgLoadingIndicator('Updating your projects view...'),
              ),
          ],
        );
      },
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
