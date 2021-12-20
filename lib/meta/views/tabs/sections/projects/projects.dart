// 🎯 Dart imports:
import 'dart:isolate';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/shared_pref.dart';
import 'package:manager/components/dialog_templates/project/new_project.dart';
import 'package:manager/components/dialog_templates/settings/settings.dart';
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/core/libraries/models.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/core/libraries/utils.dart';
import 'package:manager/core/libraries/views.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/meta/utils/bin/utils/projects.search.dart';
import 'package:manager/meta/utils/extract_pubspec.dart';
import 'package:manager/meta/views/workflows/startup.dart';

Future<void> _getProjects(SendPort sendPort) async {
  // Init shared preference once again because we are in a different isolate.
  await SharedPref.init();

  // If we have cache, we will use it to improve performance. After we send to
  // the port listener, we will then fetch again to update the cache in the
  // background.

  // The first is the list of projects, the second is a boolean. True means
  // that we want to kill the isolate and false means there is another response
  // coming in soon so don't kill the isolate. The third item in the list is a
  // boolean meaning is it refetching from cache or not.
  if (SharedPref().pref.containsKey(SPConst.projectsCache)) {
    await logger.file(
        LogTypeTag.info, 'Fetching projects from cache. Cache found.');
    List<ProjectObject> _projectsCache =
        await ProjectSearchUtils.getProjectsCache();

    sendPort.send(<dynamic>[_projectsCache, false, true]);

    List<ProjectObject> _projectsRefetch =
        await ProjectSearchUtils.getProjectsFromPath();

    sendPort.send(<dynamic>[_projectsRefetch, true, false]);
    return;
  } else {
    await logger.file(
        LogTypeTag.info, 'Fetching projects initially. No cache found.');
    List<ProjectObject> _projectsPaths =
        await ProjectSearchUtils.getProjectsFromPath();

    sendPort.send(<dynamic>[_projectsPaths, true, false]);
    return;
  }
}

class HomeProjectsSection extends StatefulWidget {
  const HomeProjectsSection({Key? key}) : super(key: key);

  @override
  _HomeProjectsSectionState createState() => _HomeProjectsSectionState();
}

class _HomeProjectsSectionState extends State<HomeProjectsSection> {
  String _searchText = '';

  final List<ProjectObject> _projects = <ProjectObject>[];

  bool _loadingSearch = false;
  bool _projectsLoading = false;
  bool _reloadingFromCache = false;

  static const int _buttonsOnRight = 2;

  final FocusNode _searchNode = FocusNode();

  final List<ProjectObject> _searchResults = <ProjectObject>[];

  final ReceivePort _loadProjectsPort = ReceivePort('find_projects_isolate');

  Future<void> _startSearch() async {
    setState(() => _loadingSearch = true);

    List<ProjectObject> _results = <ProjectObject>[];

    if (_searchText.isEmpty) {
      setState(_searchResults.clear);
      return;
    }

    String _q = removeSpaces(_searchText.toLowerCase());

    for (ProjectObject _project in _projects) {
      if (_results.length >= 5) {
        break;
      }

      List<bool> _matches = <bool>[
        removeSpaces(_project.name.toLowerCase()).contains(_q),
        _project.path.toLowerCase().contains(_q),
        if (_project.description != null)
          removeSpaces(_project.description!.toLowerCase()).contains(_q),
      ];

      if (_matches.contains(true)) {
        _results.add(_project);
      }
    }

    setState(() {
      _searchResults.clear();
      _searchResults.addAll(_results);
      _loadingSearch = false;
    });
  }

  Future<void> _loadProjects() async {
    if (SharedPref().pref.containsKey(SPConst.projectsPath)) {
      setState(() => _projectsLoading = true);

      Isolate _isolate =
          await Isolate.spawn(_getProjects, _loadProjectsPort.sendPort)
              .timeout(const Duration(minutes: 2));

      _loadProjectsPort.listen((dynamic message) {
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

  @override
  void initState() {
    _loadProjects();
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
        Column(
          children: <Widget>[
            VSeparators.normal(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Center(
                child: Row(
                  children: <Widget>[
                    if (_buttonsOnRight > 0)
                      const SizedBox(
                        width: (40 * _buttonsOnRight) +
                            ((_buttonsOnRight - 1) * 10),
                      ),
                    const Spacer(),
                    SizedBox(
                      width: (MediaQuery.of(context).size.width > 1000)
                          ? 500
                          : 400,
                      height: 40,
                      child: RoundContainer(
                        padding: EdgeInsets.zero,
                        borderColor: Colors.blueGrey.withOpacity(0.2),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 8,
                                right:
                                    _searchText == '' || !_searchNode.hasFocus
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
                                        color: Colors.grey.withOpacity(0.8),
                                        fontSize: 14,
                                      ),
                                      hintText: 'Search Projects',
                                      border: InputBorder.none,
                                      isCollapsed: true,
                                    ),
                                    onChanged: (String val) {
                                      if (val.isEmpty) {
                                        setState(() => _searchText = '');
                                        _startSearch();
                                      } else {
                                        setState(() => _searchText = val);
                                        _startSearch();
                                      }
                                    },
                                  ),
                                ),
                                HSeparators.xSmall(),
                                if (_searchText == '' || !_searchNode.hasFocus)
                                  const Icon(Icons.search_rounded, size: 16)
                                else
                                  RectangleButton(
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
                                      setState(() => _searchText = '');
                                      _searchNode.unfocus();
                                      _startSearch();
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    RectangleButton(
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.play_arrow_rounded,
                          size: 20, color: kGreenColor),
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const StartUpWorkflow(),
                        );
                      },
                    ),
                    HSeparators.small(),
                    RectangleButton(
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.add_rounded, size: 20),
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const NewProjectDialog(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 70),
          child: !SharedPref().pref.containsKey(SPConst.projectsPath)
              ? Center(
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
                        RectangleButton(
                          width: 200,
                          height: 40,
                          child: const Text('Add Path'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => const SettingDialog(
                                goToPage: 'Projects',
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                )
              : _projectsLoading
                  ? const Center(child: Spinner(thickness: 2))
                  : SingleChildScrollView(
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
                                  ),
                                  VSeparators.normal(),
                                  Expanded(
                                    child: Text(
                                      e.description ?? 'No description found',
                                      style:
                                          const TextStyle(color: Colors.grey),
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
                                    waitDuration:
                                        const Duration(milliseconds: 500),
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
                                          onPressed: () {},
                                        ),
                                      ),
                                      HSeparators.xSmall(),
                                      HSeparators.xSmall(),
                                      RectangleButton(
                                        width: 40,
                                        height: 40,
                                        padding: EdgeInsets.zero,
                                        child: const Icon(
                                            Icons.play_arrow_rounded,
                                            color: kGreenColor),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (_) => StartUpWorkflow(
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
        ),
        // Show the search results in realtime if the user has typed anything
        // to search for.
        if (_searchText != '')
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 500,
                  maxHeight: 300,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).isDarkTheme
                      ? const Color(0xff262F34)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Colors.blueGrey.withOpacity(0.4),
                  ),
                ),
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _searchResults.isEmpty
                        ? <Widget>[
                            if (_loadingSearch)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: LinearProgressIndicator(
                                  backgroundColor: Colors.blue.withOpacity(0.1),
                                ),
                              )
                            else
                              informationWidget(
                                'There are no results for your search query. Try using another term instead.',
                                type: InformationType.error,
                              ),
                          ]
                        : _searchResults.map((ProjectObject e) {
                            double _pad = _searchResults.indexOf(e) ==
                                    _searchResults.length - 1
                                ? 0
                                : 5;
                            return Padding(
                              padding: EdgeInsets.only(bottom: _pad),
                              child: ProjectSearchResultTile(project: e),
                            );
                          }).toList(),
                  ),
                ),
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
