// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/dialog_templates/other/status.dart';
import 'package:fluttermatic/components/dialog_templates/project/create_select.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/linear_progress_indicator.dart';
import 'package:fluttermatic/components/widgets/ui/load_activity_msg.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/components/widgets/ui/stage_tile.dart';
import 'package:fluttermatic/core/models/projects.model.dart';
import 'package:fluttermatic/core/notifiers/notifications.notifier.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';
import 'package:fluttermatic/meta/utils/bin/utils/projects.search.dart';
import 'package:fluttermatic/meta/utils/bin/utils/search.dart';
import 'package:fluttermatic/meta/utils/bin/utils/workflow.search.dart';
import 'package:fluttermatic/meta/views/dialogs/notifications/notification_view.dart';
import 'package:fluttermatic/meta/views/tabs/search/elements/package.dart';
import 'package:fluttermatic/meta/views/tabs/search/elements/projects.dart';
import 'package:fluttermatic/meta/views/tabs/search/elements/workflows.dart';
import 'package:fluttermatic/meta/views/tabs/sections/pub/models/pkg_data.dart';
import 'package:fluttermatic/meta/views/workflows/startup.dart';

class HomeSearchComponent extends StatefulWidget {
  const HomeSearchComponent({Key? key}) : super(key: key);

  @override
  _HomeSearchComponentState createState() => _HomeSearchComponentState();
}

class _HomeSearchComponentState extends State<HomeSearchComponent> {
  // Inputs
  final TextEditingController _searchController = TextEditingController();

  // Utils
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

      Duration _cacheDuration = const Duration(minutes: 5);

      bool _isCacheValid = false;

      if (_lastCacheUpdate == null) {
        _isCacheValid = false;
      } else {
        _isCacheValid =
            _lastCacheUpdate!.add(_cacheDuration).isAfter(DateTime.now());
      }

      if (!_isCacheValid) {
        // Clear the existing cache.
        _projects.clear();
        _workflows.clear();

        // Get the latest cache information.
        _projects.addAll(await ProjectSearchUtils.getProjectsFromCache(_path!));
        _workflows
            .addAll(await WorkflowSearchUtils.getWorkflowsFromCache(_path!));

        // Update the last cache update time.
        _lastCacheUpdate = DateTime.now();
      }

      // Wait 250 ms before starting the search. Make sure that the search query
      // before and after didn't change to avoid unnecessary searches.
      String _before = _searchController.text;

      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Ensure that we are still in the same search query.
      if (_before != _searchController.text) {
        return;
      }

      Stream<List<dynamic>> _searchStream = AppGlobalSearch.search(
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

      _searchStream.asBroadcastStream().listen((List<dynamic> data) {
        String _type = data[0];
        List<dynamic> _results = data[1];
        String _forQuery = data[2];

        // Make sure this is the latest search result, and not one for a
        // previous query request. This is for the case where the user
        // is typing a query, and the search results are being updated
        // as the user types but couldn't catch up with the user typing
        // the query.
        if (_searchController.text != _forQuery) {
          return;
        }

        switch (_type) {
          case 'projects':
            _projectResults.clear();
            _projectResults
                .addAll(_results.map((dynamic d) => d as ProjectObject));
            break;
          case 'workflows':
            _workflowResults.clear();
            _workflowResults.addAll(
                _results.map((dynamic d) => d as ProjectWorkflowsGrouped));
            break;
          case 'packages':
            _packageResults.clear();
            _packageResults
                .addAll(_results.map((dynamic d) => d as PkgViewData));
            break;
        }
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
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
        context,
        'Failed to search for some reason. Please try again.',
        type: SnackBarType.error,
      ));
    }
  }

  @override
  void dispose() {
    _searchNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                width: (MediaQuery.of(context).size.width > 1000) ? 500 : 400,
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
                                color: (Theme.of(context).isDarkTheme
                                        ? Colors.white
                                        : Colors.black)
                                    .withOpacity(0.8),
                              ),
                              cursorRadius: const Radius.circular(5),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                  color: (Theme.of(context).isDarkTheme
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
                                  color: Theme.of(context).isDarkTheme
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
                    color: Theme.of(context).isDarkTheme
                        ? const Color(0xff262F34)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.blueGrey.withOpacity(0.4)),
                  ),
                  // padding: const EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <dynamic>[
                        ..._packageResults,
                        ..._projectResults,
                        ..._workflowResults
                      ].isEmpty
                          ? <Widget>[
                              if (!_loadingSearch) ...<Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  child: Row(
                                    children: <Widget>[
                                      const StageTile(
                                          stageType: StageType.prerelease),
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
                                const LoadActivityMessageElement(message: ''),
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
                                      StageTile(
                                          stageType: StageType.prerelease),
                                    ],
                                  ),
                                ),
                                VSeparators.small(),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 15),
                                  child: SizedBox(
                                    height: 150,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
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
                                    padding: const EdgeInsets.only(bottom: 15),
                                    child: SearchWorkflowsTile(workflow: _))),
                              if (_packageResults.isNotEmpty) ...<Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 10),
                                  child: Row(
                                    children: const <Widget>[
                                      Expanded(
                                        child: Text('Pub Packages',
                                            style: TextStyle(fontSize: 18)),
                                      ),
                                      StageTile(
                                          stageType: StageType.prerelease),
                                    ],
                                  ),
                                ),
                                VSeparators.small(),
                                SizedBox(
                                  height: 150,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _packageResults.length,
                                    itemBuilder: (_, int i) {
                                      return SearchPackageTile(
                                          package: _packageResults[i]);
                                    },
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
  }
}

class _NotificationsButton extends StatefulWidget {
  const _NotificationsButton({Key? key}) : super(key: key);

  @override
  State<_NotificationsButton> createState() => _NotificationsButtonState();
}

class _NotificationsButtonState extends State<_NotificationsButton> {
  int _notificationsCount = 0;
  bool _hasNotifications = false;

  Future<void> _reloadOnNotification() async {
    while (mounted) {
      await Future<void>.delayed(const Duration(seconds: 3));

      if (mounted &&
          context.read<NotificationsNotifier>().notifications.isNotEmpty) {
        if (!_hasNotifications && mounted) {
          setState(() => _hasNotifications = true);
        }
      } else {
        if (_hasNotifications && mounted) {
          setState(() => _hasNotifications = false);
        }
      }

      if (mounted &&
          context.read<NotificationsNotifier>().notifications.length !=
              _notificationsCount) {
        setState(() => _notificationsCount =
            context.read<NotificationsNotifier>().notifications.length);
      }
    }
  }

  @override
  void initState() {
    _reloadOnNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.read<NotificationsNotifier>().notifications.isEmpty
          ? 'No Notifications'
          : 'Notifications (${context.read<NotificationsNotifier>().notifications.length})',
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
              opacity: _hasNotifications ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              child: const RoundContainer(
                child: SizedBox.shrink(),
                color: kRedColor,
                radius: 20,
                height: 10,
                width: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
