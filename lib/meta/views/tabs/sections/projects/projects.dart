// 🎯 Dart imports:
import 'dart:isolate';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/shared_pref.dart';
import 'package:manager/components/dialog_templates/settings/settings.dart';
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/core/libraries/models.dart';
import 'package:manager/core/libraries/utils.dart';
import 'package:manager/core/libraries/views.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/meta/utils/bin/utils/projects.search.dart';
import 'package:manager/meta/utils/extract_pubspec.dart';
import 'package:manager/meta/views/workflows/startup.dart';

Future<void> _getProjects(SendPort send) async {
  // Init shared preference once again because we are in a different isolate.
  await SharedPref.init();
  List<ProjectObject> _projectsPaths =
      await ProjectSearchUtils.getProjectsFromPath();

  send.send(_projectsPaths);
}

void _applySearch(List<dynamic> info) {
  String _search = info[0];
  List<ProjectObject> _projectsPaths = info[1];
  SendPort _sendPort = info[2];

  List<ProjectObject> _results = <ProjectObject>[];

  if (_search.isEmpty) {
    _sendPort.send(_results);
    return;
  }

  String _q = removeSpaces(_search.toLowerCase());

  for (ProjectObject _project in _projectsPaths) {
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

  _sendPort.send(_results);
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

  static const int _buttonsOnRight = 1;

  final FocusNode _searchNode = FocusNode();

  final List<ProjectObject> _searchResults = <ProjectObject>[];

  final ReceivePort _searchPort = ReceivePort('projects_search_isolate');
  final ReceivePort _loadProjectsPort = ReceivePort('find_projects_isolate');

  Future<void> _startSearch() async {
    setState(() => _loadingSearch = true);

    Isolate _isolate = await Isolate.spawn(
        _applySearch, <dynamic>[_searchText, _projects, _searchPort.sendPort]);

    _searchPort.listen((dynamic _results) {
      if (_results is List<ProjectObject>) {
        setState(() {
          _searchResults.clear();
          _searchResults.addAll(_results);
          _loadingSearch = false;
        });
        _isolate.kill();
      }
    });
  }

  Future<void> _loadProjects() async {
    if (SharedPref().pref.containsKey(SPConst.projectsPath)) {
      setState(() => _projectsLoading = true);

      Isolate _isolate =
          await Isolate.spawn(_getProjects, _loadProjectsPort.sendPort)
              .timeout(const Duration(minutes: 2));

      _loadProjectsPort.listen((dynamic message) {
        if (message is List<ProjectObject>) {
          setState(() {
            _projectsLoading = false;
            _projects.addAll(message);
          });
          _isolate.kill(priority: Isolate.immediate);
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
    _searchPort.close();
    _loadProjectsPort.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
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
                  ],
                ),
              ),
            ),
          ],
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
                      child: Column(
                        children: _projects
                            .map((ProjectObject e) => Text(e.name))
                            .toList(),
                      ),
                    ),
        )
      ],
    );
  }
}
