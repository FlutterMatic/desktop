// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttermatic/core/notifiers/notifiers/general/notifications.dart';
import 'package:path_provider/path_provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/other/status.dart';
import 'package:fluttermatic/components/dialog_templates/project/create_select.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/linear_progress_indicator.dart';
import 'package:fluttermatic/components/widgets/ui/load_activity_msg.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/components/widgets/ui/spinner.dart';
import 'package:fluttermatic/components/widgets/ui/stage_tile.dart';
import 'package:fluttermatic/core/models/projects.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/theme.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/search/search.dart';
import 'package:fluttermatic/meta/utils/search/workflow_search.dart';
import 'package:fluttermatic/meta/views/dialogs/notifications/notification_view.dart';
import 'package:fluttermatic/meta/views/tabs/search/elements/package.dart';
import 'package:fluttermatic/meta/views/tabs/search/elements/projects.dart';
import 'package:fluttermatic/meta/views/tabs/search/elements/workflows.dart';
import 'package:fluttermatic/meta/views/tabs/sections/pub/models/pkg_data.dart';
import 'package:fluttermatic/meta/views/workflows/startup.dart';

class HomeSearchComponent extends ConsumerStatefulWidget {
  const HomeSearchComponent({Key? key}) : super(key: key);

  @override
  _HomeSearchComponentState createState() => _HomeSearchComponentState();
}

class _HomeSearchComponentState extends ConsumerState<HomeSearchComponent> {
  // Inputs
  final TextEditingController _searchController = TextEditingController();

  // Utils
  bool _loadingPub = false;
  bool _loadingSearch = false;
  final FocusNode _searchNode = FocusNode();

  // Search Results
  final List<ProjectObject> _projectResults = <ProjectObject>[];
  final List<ProjectWorkflowsGrouped> _workflowResults =
      <ProjectWorkflowsGrouped>[];

  final List<PkgViewData> _packageResults = <PkgViewData>[];

  String? _path;

  DateTime? _lastCacheUpdate;

  final List<ProjectObject> _projects = <ProjectObject>[];
  final List<ProjectWorkflowsGrouped> _workflows = <ProjectWorkflowsGrouped>[];

  // Search will be able to search multiple FM services. This means that we
  // need to perform multiple searches and display the results in a list
  // (merged and sorted by either importance, relevance, or date).
  //
  // This needs to be done in an efficient manner.
  Future<void> _search() async {
    try {
      setState(() => _loadingSearch = true);

      _path ??= (await getApplicationSupportDirectory()).path;

      if (_searchController.text.isEmpty) {
        setState(() {
          _projectResults.clear();
          _workflowResults.clear();
          _packageResults.clear();
          _loadingSearch = false;
        });
        return;
      }

      Duration cacheDuration = const Duration(minutes: 5);

      bool isCacheValid = false;

      if (_lastCacheUpdate == null) {
        isCacheValid = false;
      } else {
        isCacheValid =
            _lastCacheUpdate!.add(cacheDuration).isAfter(DateTime.now());
      }

      if (!isCacheValid) {
        // Clear the existing cache.
        _projects.clear();
        _workflows.clear();

        // Get the latest cache information.
        _projects.addAll([
          ...ref.watch(projectsActionStateNotifier.notifier).pinned,
          ...ref.watch(projectsActionStateNotifier.notifier).flutter,
          ...ref.watch(projectsActionStateNotifier.notifier).dart,
        ]);

        _workflows
            .addAll(await WorkflowSearchUtils.getWorkflowsFromCache(_path!));

        // Update the last cache update time.
        _lastCacheUpdate = DateTime.now();
      }

      // Wait a duration before starting the search. Make sure that the search
      // query before and after didn't change to avoid unnecessary searches.
      String before = _searchController.text;

      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Ensure that we are still in the same search query.
      if (before != _searchController.text) {
        return;
      }

      Stream<List<dynamic>> searchStream = AppGlobalSearch.search(
        query: _searchController.text,
        path: _path!,
        projects: _projects,
        workflows: _workflows,
      ).timeout(const Duration(seconds: 5), onTimeout: (_) {
        setState(() {
          _projectResults.clear();
          _workflowResults.clear();
          _packageResults.clear();
          _loadingSearch = false;
        });
      });

      searchStream.asBroadcastStream().listen((List<dynamic> data) {
        String type = data[0];
        List<dynamic> results = data[1];
        String forQuery = data[2];

        // Make sure this is the latest search result, and not one for a
        // previous query request. This is for the case where the user
        // is typing a query, and the search results are being updated
        // as the user types but couldn't catch up with the user typing
        // the query.
        if (_searchController.text != forQuery && type != 'loading') {
          return;
        }

        switch (type) {
          case 'projects':
            _projectResults.clear();
            _projectResults
                .addAll(results.map((dynamic d) => d as ProjectObject));
            break;
          case 'workflows':
            _workflowResults.clear();
            _workflowResults.addAll(
                results.map((dynamic d) => d as ProjectWorkflowsGrouped));
            break;
          case 'packages':
            _packageResults.clear();
            _packageResults
                .addAll(results.map((dynamic d) => d as PkgViewData));
            break;
          case 'loading':
            if (results[0] == 'pub') {
              _loadingPub = forQuery != 'done';
              if (forQuery == 'error') {
                logger.file(LogTypeTag.error, 'Pub search error');
              }
            }
        }

        setState(() {});
      });

      setState(() => _loadingSearch = false);
    } catch (_, s) {
      setState(() {
        _projectResults.clear();
        _workflowResults.clear();
        _packageResults.clear();
        _searchController.clear();
        _loadingSearch = false;
      });

      await logger.file(
          LogTypeTag.error, 'Failed to search in main component: $_',
          stackTraces: s);

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
          context,
          'Failed to search for some reason. Please try again.',
          type: SnackBarType.error,
        ));
      }
    }
  }

  @override
  void dispose() {
    _searchNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        ThemeState themeState = ref.watch(themeStateController);

        return Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
          child: Stack(
            fit: StackFit.loose,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Tooltip(
                    message: 'New Project',
                    waitDuration: const Duration(seconds: 1),
                    child: RectangleButton(
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.add_rounded, size: 20),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const SelectProjectTypeDialog(),
                        );
                      },
                    ),
                  ),
                  HSeparators.small(),
                  Tooltip(
                    message: 'Status',
                    waitDuration: const Duration(seconds: 1),
                    child: RectangleButton(
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.analytics_rounded, size: 20),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const StatusDialog(),
                        );
                      },
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width:
                        (MediaQuery.of(context).size.width > 1000) ? 500 : 400,
                    height: 40,
                    child: RoundContainer(
                      padding: EdgeInsets.zero,
                      borderColor: Colors.blueGrey.withOpacity(0.2),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 8,
                              right: _searchController.text.isEmpty ||
                                      !_searchNode.hasFocus
                                  ? 8
                                  : 5),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: TextFormField(
                                  focusNode: _searchNode,
                                  style: TextStyle(
                                    color: (themeState.darkTheme
                                            ? Colors.white
                                            : Colors.black)
                                        .withOpacity(0.8),
                                  ),
                                  cursorRadius: const Radius.circular(5),
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                      color: (themeState.darkTheme
                                              ? Colors.white
                                              : Colors.black)
                                          .withOpacity(0.6),
                                      fontSize: 14,
                                    ),
                                    hintText:
                                        'Search projects, packages, workflows...',
                                    border: InputBorder.none,
                                    isCollapsed: true,
                                  ),
                                  controller: _searchController,
                                  onChanged: (_) {
                                    setState(() {});
                                    _search(); // Call search
                                  },
                                ),
                              ),
                              HSeparators.xSmall(),
                              if (_searchController.text.isEmpty ||
                                  !_searchNode.hasFocus)
                                const Icon(Icons.search_rounded, size: 16)
                              else
                                Tooltip(
                                  message: 'Cancel',
                                  waitDuration: const Duration(seconds: 1),
                                  child: RectangleButton(
                                    width: 30,
                                    height: 30,
                                    padding: const EdgeInsets.all(5),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 13,
                                      color: themeState.darkTheme
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    onPressed: () {
                                      _searchNode.unfocus();
                                      _searchController.clear();
                                      setState(() {
                                        _packageResults.clear();
                                        _projectResults.clear();
                                        _workflowResults.clear();
                                      });
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Tooltip(
                    message: 'New Workflow',
                    waitDuration: const Duration(seconds: 1),
                    child: RectangleButton(
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.play_arrow_rounded,
                          size: 20, color: kGreenColor),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const StartUpWorkflow(),
                        );
                      },
                    ),
                  ),
                  HSeparators.small(),
                  const _NotificationsButton(),
                ],
              ),
              // Show the search results in realtime if the user has typed
              // anything to search for.
              if (_searchController.text.isNotEmpty)
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Container(
                      width: 500,
                      constraints: const BoxConstraints(
                        maxWidth: 500,
                        maxHeight: 500,
                      ),
                      decoration: BoxDecoration(
                        color: themeState.darkTheme
                            ? const Color(0xff262F34)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border:
                            Border.all(color: Colors.blueGrey.withOpacity(0.4)),
                      ),
                      // padding: const EdgeInsets.all(10),
                      child: SingleChildScrollView(
                        key: const ValueKey<String>('search-results'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: (<dynamic>[
                                    ..._packageResults,
                                    ..._projectResults,
                                    ..._workflowResults
                                  ].isEmpty &&
                                  !_loadingPub)
                              ? <Widget>[
                                  if (!_loadingSearch) ...<Widget>[
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 10, 10, 0),
                                      child: Row(
                                        children: <Widget>[
                                          const StageTile(),
                                          HSeparators.normal(),
                                          const Expanded(
                                            child: Text(
                                                'The search feature is still an experimental feature and you have access to an early preview.'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    VSeparators.normal(),
                                    if (_loadingSearch)
                                      const CustomLinearProgressIndicator(
                                          includeBox: false)
                                    else
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 0, 10, 10),
                                        child: informationWidget(
                                          'There are no results for your search query. Try using another term instead.',
                                          type: InformationType.error,
                                        ),
                                      ),
                                  ] else
                                    const Padding(
                                      padding: EdgeInsets.all(5),
                                      child: LoadActivityMessageElement(
                                          message: ''),
                                    ),
                                ]
                              : <Widget>[
                                  if (_projectResults.isNotEmpty) ...<Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10, top: 10),
                                      child: Row(
                                        children: const <Widget>[
                                          Expanded(
                                            child: Text('Projects',
                                                style: TextStyle(fontSize: 18)),
                                          ),
                                          StageTile(),
                                        ],
                                      ),
                                    ),
                                    VSeparators.small(),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: SizedBox(
                                        height: 150,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          key: const ValueKey<String>(
                                              'project-list'),
                                          itemCount: _projectResults.length,
                                          itemBuilder: (_, int i) {
                                            return SearchProjectTile(
                                                project: _projectResults[i]);
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (_workflowResults.isNotEmpty)
                                    ..._workflowResults.map((_) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child:
                                            SearchWorkflowsTile(workflow: _))),
                                  if (_loadingPub && _packageResults.isEmpty)
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          10,
                                          <dynamic>[
                                            ..._packageResults,
                                            ..._projectResults,
                                            ..._workflowResults
                                          ].isEmpty
                                              ? 10
                                              : 0,
                                          10,
                                          10),
                                      child: const LoadActivityMessageElement(
                                          message: 'Searching Pub packages'),
                                    )
                                  else if (!_loadingPub &&
                                      _packageResults.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 0, 10, 10),
                                      child: RoundContainer(
                                        child: Row(
                                          children: <Widget>[
                                            SvgPicture.asset(Assets.package,
                                                color: themeState.darkTheme
                                                    ? Colors.white
                                                    : Colors.blueGrey,
                                                height: 20),
                                            HSeparators.xSmall(),
                                            const Text(
                                                'No packages found with your search query.'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (_packageResults.isNotEmpty) ...<Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10, top: 10),
                                      child: Row(
                                        children: <Widget>[
                                          const Expanded(
                                            child: Text('Pub Packages',
                                                style: TextStyle(fontSize: 18)),
                                          ),
                                          if (_loadingPub)
                                            const Spinner(
                                                size: 14, thickness: 2),
                                          HSeparators.small(),
                                          const StageTile(),
                                        ],
                                      ),
                                    ),
                                    VSeparators.small(),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: SizedBox(
                                        height: 150,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          key: const ValueKey<String>(
                                              'package-list'),
                                          itemCount: _packageResults.length,
                                          itemBuilder: (_, int i) {
                                            return SearchPackageTile(
                                                package: _packageResults[i]);
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _NotificationsButton extends StatelessWidget {
  const _NotificationsButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, __) {
        NotificationsNotifier notificationsNotifier =
            ref.watch(notificationStateController.notifier);

        return Tooltip(
          message: notificationsNotifier.notifications.isEmpty
              ? 'No Notifications'
              : 'Notifications (${notificationsNotifier.notifications.length})',
          waitDuration: const Duration(seconds: 1),
          child: Stack(
            children: <Widget>[
              RectangleButton(
                width: 40,
                height: 40,
                child: Icon(Icons.notifications_outlined,
                    color: Colors.yellow[900], size: 20),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const NotificationViewDialog(),
                  );
                },
              ),
              Positioned(
                right: 10,
                top: 10,
                child: AnimatedOpacity(
                  opacity:
                      notificationsNotifier.notifications.isNotEmpty ? 1 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: const RoundContainer(
                    color: kRedColor,
                    radius: 20,
                    height: 10,
                    width: 10,
                    child: SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
