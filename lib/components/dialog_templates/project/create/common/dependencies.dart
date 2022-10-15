// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermatic/core/models/pub_cache.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/load_activity_msg.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/theme.dart';
import 'package:fluttermatic/core/notifiers/out.dart';

class ProjectDependenciesSection extends StatefulWidget {
  final List<String> dependencies;
  final List<String> devDependencies;
  final Function(List<String> newDependencies) onDependenciesChanged;
  final Function(List<String> newDevDependencies) onDevDependenciesChanged;

  const ProjectDependenciesSection({
    Key? key,
    required this.dependencies,
    required this.devDependencies,
    required this.onDependenciesChanged,
    required this.onDevDependenciesChanged,
  }) : super(key: key);

  @override
  State<ProjectDependenciesSection> createState() =>
      _ProjectDependenciesSectionState();
}

class _ProjectDependenciesSectionState
    extends State<ProjectDependenciesSection> {
  // Controllers
  final FocusNode _searchNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  List<String> _pubPackages = <String>[];
  List<String> _searchResults = <String>[];

  static const int _maxResults = 100;
  bool _loading = true;

  void _performSearch(String q) {
    q = q.toLowerCase();

    if (q.isEmpty) {
      setState(() => _searchResults = _pubPackages.length > _maxResults
          ? _pubPackages.sublist(0, _maxResults)
          : _pubPackages);
      return;
    }

    List<String> split = q.split(' ');

    List<String> results = _pubPackages.where((String package) {
      if (package.toLowerCase() == q) {
        return true;
      }

      int totalMatches = 0;

      // Needs to have 80% of the words to be a match
      for (String word in split) {
        if (package.toLowerCase().contains(word)) {
          totalMatches++;
        }
      }

      return totalMatches == split.length;
    }).toList();

    setState(() {
      _searchResults = results.length > _maxResults
          ? results.sublist(0, _maxResults)
          : results;

      if (_searchResults.isEmpty) {
        _searchResults = _pubPackages.length > _maxResults
            ? _pubPackages.sublist(0, _maxResults)
            : _pubPackages;
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
          context,
          'No results found. Try entering the package name itself.',
          type: SnackBarType.error,
        ));
      }
    });
  }

  Future<void> _getPubPackages() async {
    List<String> packages = await PubCache.getCache();

    setState(() {
      _pubPackages = packages;
      _loading = false;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getPubPackages();
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_pubPackages.isEmpty && !_loading) {
      return Column(
        children: <Widget>[
          informationWidget(
              'To pre-add dependencies or dev-dependencies, please make sure you have an internet connection. This requires an internet connection to fetch the list of packages.'),
          VSeparators.normal(),
          infoWidget(context,
              'You can skip this part if you want to add dependencies later.'),
        ],
      );
    } else if (_pubPackages.isEmpty) {
      return Column(
        children: <Widget>[
          infoWidget(
              context, 'Hold on while we fetch the list of Pub packages.'),
          VSeparators.normal(),
          const LoadActivityMessageElement(message: ''),
        ],
      );
    } else {
      return Consumer(
        builder: (_, ref, __) {
          ThemeState themeState = ref.watch(themeStateController);

          return Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  RoundContainer(
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
                              hintText: 'Search dependencies to add',
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                            controller: _searchController,
                            onChanged: _performSearch,
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
                              onPressed: () => setState(() {
                                _searchNode.unfocus();
                                _searchController.clear();
                              }),
                            ),
                          ),
                      ],
                    ),
                  ),
                  VSeparators.small(),
                  RoundContainer(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('Dependencies'),
                        VSeparators.normal(),
                        if (widget.dependencies.isEmpty)
                          const Text('No dependencies added',
                              style: TextStyle(color: Colors.grey))
                        else
                          Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: widget.dependencies.map((String e) {
                              return _dependencyTile(
                                context,
                                name: e,
                                isDarkTheme: themeState.darkTheme,
                                onRemove: () {
                                  List<String> newDependencies =
                                      widget.dependencies;

                                  newDependencies.remove(e);

                                  widget.onDependenciesChanged(newDependencies);

                                  setState(() {});
                                },
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                  VSeparators.small(),
                  RoundContainer(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('Dev Dependencies'),
                        VSeparators.normal(),
                        if (widget.devDependencies.isEmpty)
                          const Text('No dev dependencies added',
                              style: TextStyle(color: Colors.grey))
                        else
                          Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: widget.devDependencies.map((String e) {
                              return _dependencyTile(
                                context,
                                name: e,
                                isDarkTheme: themeState.darkTheme,
                                onRemove: () {
                                  List<String> newDependencies =
                                      widget.devDependencies;

                                  newDependencies.remove(e);

                                  widget.onDevDependenciesChanged(
                                      newDependencies);

                                  setState(() {});
                                },
                              );
                            }).toList(),
                          )
                      ],
                    ),
                  ),
                  if (_searchController.text.isNotEmpty) ...<Widget>[
                    VSeparators.xLarge(),
                    VSeparators.xLarge(),
                  ],
                ],
              ),
              if (_searchController.text.isNotEmpty)
                Positioned(
                  top: 45,
                  left: 0,
                  right: 0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: RoundContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        color: themeState.darkTheme
                            ? Colors.blueGrey[900]
                            : Colors.blueGrey[50],
                        borderColor: themeState.darkTheme
                            ? Colors.blueGrey[600]
                            : Colors.blueGrey[200],
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _searchResults.length > 100
                              ? 100
                              : _searchResults.length,
                          itemBuilder: (_, int i) {
                            bool isFirst = i == 0;

                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom: 5, top: isFirst ? 5 : 0),
                              child: _PackageTile(
                                packageName: _searchResults[i],
                                onAdd: () {
                                  List<String> newDependencies =
                                      widget.dependencies;

                                  if (newDependencies
                                      .contains(_searchResults[i])) {
                                    ScaffoldMessenger.of(context)
                                        .clearSnackBars();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBarTile(
                                      context,
                                      'This dependency has already been added.',
                                      type: SnackBarType.done,
                                    ));
                                    return;
                                  }

                                  newDependencies.add(_searchResults[i]);

                                  widget.onDependenciesChanged(newDependencies);

                                  setState(() {
                                    _searchController.clear();
                                    _searchNode.unfocus();
                                  });
                                },
                                onAddAsDev: () {
                                  List<String> newDependencies =
                                      widget.devDependencies;

                                  if (newDependencies
                                      .contains(_searchResults[i])) {
                                    ScaffoldMessenger.of(context)
                                        .clearSnackBars();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBarTile(
                                      context,
                                      'This dev dependency has already been added.',
                                      type: SnackBarType.done,
                                    ));
                                    return;
                                  }

                                  newDependencies.add(_searchResults[i]);

                                  widget.onDevDependenciesChanged(
                                      newDependencies);

                                  setState(() {
                                    _searchController.clear();
                                    _searchNode.unfocus();
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );
    }
  }
}

Widget _dependencyTile(
  BuildContext context, {
  required bool isDarkTheme,
  required String name,
  required Function() onRemove,
}) {
  return RoundContainer(
    color: Colors.blueGrey.withOpacity(isDarkTheme ? 0.2 : 0.1),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(name),
        HSeparators.xSmall(),
        SquareButton(
          tooltip: 'Remove',
          icon: const Icon(Icons.close, size: 10),
          size: 20,
          onPressed: onRemove,
        ),
      ],
    ),
  );
}

class _PackageTile extends StatefulWidget {
  final String packageName;
  final Function() onAdd;
  final Function() onAddAsDev;

  const _PackageTile({
    Key? key,
    required this.packageName,
    required this.onAdd,
    required this.onAddAsDev,
  }) : super(key: key);

  @override
  __PackageTileState createState() => __PackageTileState();
}

class __PackageTileState extends State<_PackageTile> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: RoundContainer(
        child: Row(
          children: <Widget>[
            Expanded(child: Text(widget.packageName, maxLines: 1)),
            HSeparators.normal(),
            if (_isHovering) ...<Widget>[
              InkWell(
                onTap: widget.onAddAsDev,
                child: const Text('Add as dev'),
              ),
              HSeparators.xSmall(),
              const Text('•'),
              HSeparators.xSmall(),
              InkWell(onTap: widget.onAdd, child: const Text('Add')),
            ]
          ],
        ),
      ),
    );
  }
}
