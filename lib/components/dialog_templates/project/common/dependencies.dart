// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/src/provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/info_widget.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/load_activity_msg.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/core/notifiers/theme.notifier.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';

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

  bool _isError = false;
  List<String> _pubPackages = <String>[];
  List<String> _searchResults = <String>[];

  static const int _maxResults = 100;

  void _performSearch(String q) {
    q = q.toLowerCase();

    if (q.isEmpty) {
      setState(() => _searchResults = _pubPackages.length > _maxResults
          ? _pubPackages.sublist(0, _maxResults)
          : _pubPackages);
      return;
    }

    List<String> _split = q.split(' ');

    List<String> _results = _pubPackages.where((String package) {
      if (package.toLowerCase() == q) {
        return true;
      }

      int _totalMatches = 0;

      // Needs to have 80% of the words to be a match
      for (String word in _split) {
        if (package.toLowerCase().contains(word)) {
          _totalMatches++;
        }
      }

      return _totalMatches == _split.length;
    }).toList();

    setState(() {
      _searchResults = _results.length > _maxResults
          ? _results.sublist(0, _maxResults)
          : _results;

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
    File _cache = File((await getApplicationSupportDirectory()).path +
        '\\cache\\pub_packages.json');

    if (await _cache.exists()) {
      // Will make sure it has been less than 10 minutes since the last time we
      // updated the cache.
      Map<String, dynamic> _cachePackages =
          jsonDecode(await _cache.readAsString());

      bool _isCacheValid = DateTime.now()
              .difference(DateTime.fromMillisecondsSinceEpoch(
                  _cachePackages['last_updated']))
              .inMinutes <
          10;

      if (_cachePackages['last_updated'] != null && _isCacheValid) {
        setState(() => _pubPackages =
            (_cachePackages['packages'] as List<dynamic>)
                .map((_) => _.toString())
                .toList()
                .where((String e) =>
                    !widget.dependencies.contains(e) &&
                    !widget.devDependencies.contains(e))
                .toList());
        return;
      }
    }

    String _url = 'https://pub.dev/api/package-name-completion-data';

    http.Response _response = await http.get(Uri.parse(_url));

    if (_response.statusCode != 200 && mounted) {
      setState(() => _isError = true);
      await Future<void>.delayed(const Duration(seconds: 5));
      // ignore: unawaited_futures
      _getPubPackages();
      return;
    } else if (mounted) {
      List<dynamic> _packages =
          ((jsonDecode(_response.body) as Map<String, dynamic>).entries.first)
              .value as List<dynamic>;

      setState(() => _pubPackages.addAll(_packages
          .map((_) => _.toString())
          .toList()
          .where((String e) =>
              !widget.dependencies.contains(e) &&
              !widget.devDependencies.contains(e))
          .toList()));

      // Will update the cache file.
      Map<String, dynamic> _cacheData = <String, dynamic>{
        'last_updated': DateTime.now().millisecondsSinceEpoch,
        'packages': _packages.map((_) => _.toString()).toList(),
      };

      await _cache.writeAsString(jsonEncode(_cacheData));
    }
  }

  @override
  void initState() {
    _getPubPackages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_pubPackages.isEmpty && _isError) {
      return Column(
        children: <Widget>[
          informationWidget(
              'To pre-add dependencies or dev-dependencies, please make sure you have an internet connection. This requires an internet connection to fetch the list of packages.'),
          VSeparators.normal(),
          infoWidget(context,
              'You can skip this part if you want to add dependencies later.'),
        ],
      );
    } else if (_pubPackages.isEmpty && !_isError) {
      return Column(
        children: <Widget>[
          infoWidget(
              context, 'Hold on while we fetch the list of Pub packages.'),
          VSeparators.normal(),
          const LoadActivityMessageElement(message: ''),
        ],
      );
    } else {
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
                          hintText: 'Search dependencies to add',
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                        controller: _searchController,
                        onChanged: _performSearch,
                      ),
                    ),
                    HSeparators.xSmall(),
                    if (_searchController.text.isEmpty || !_searchNode.hasFocus)
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
                          return _dependencyTile(context, name: e,
                              onRemove: () {
                            List<String> _newDependencies =
                                widget.dependencies;

                            _newDependencies.remove(e);

                            widget.onDependenciesChanged(_newDependencies);

                            setState(() {});
                          });
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
                            onRemove: () {
                              List<String> _newDependencies =
                                  widget.devDependencies;

                              _newDependencies.remove(e);

                              widget.onDevDependenciesChanged(
                                  _newDependencies);

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
                    color: context.read<ThemeChangeNotifier>().isDarkTheme
                        ? Colors.blueGrey[900]
                        : Colors.blueGrey[50],
                    borderColor: context.read<ThemeChangeNotifier>().isDarkTheme
                        ? Colors.blueGrey[600]
                        : Colors.blueGrey[200],
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length > 100
                          ? 100
                          : _searchResults.length,
                      itemBuilder: (_, int i) {
                        bool _isFirst = i == 0;

                        return Padding(
                          padding:
                              EdgeInsets.only(bottom: 5, top: _isFirst ? 5 : 0),
                          child: _PackageTile(
                            packageName: _searchResults[i],
                            onAdd: () {
                              List<String> _newDependencies =
                                  widget.dependencies;

                              if (_newDependencies
                                  .contains(_searchResults[i])) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBarTile(
                                  context,
                                  'This dependency has already been added.',
                                  type: SnackBarType.done,
                                ));
                                return;
                              }

                              _newDependencies.add(_searchResults[i]);

                              widget.onDependenciesChanged(_newDependencies);

                              setState(() {
                                _searchController.clear();
                                _searchNode.unfocus();
                              });
                            },
                            onAddAsDev: () {
                              List<String> _newDependencies =
                                  widget.devDependencies;

                              if (_newDependencies
                                  .contains(_searchResults[i])) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBarTile(
                                  context,
                                  'This dev dependency has already been added.',
                                  type: SnackBarType.done,
                                ));
                                return;
                              }

                              _newDependencies.add(_searchResults[i]);

                              widget.onDevDependenciesChanged(_newDependencies);

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
    }
  }
}

Widget _dependencyTile(
  BuildContext context, {
  required String name,
  required Function() onRemove,
}) {
  return RoundContainer(
    color: Colors.blueGrey.withOpacity(
        context.read<ThemeChangeNotifier>().isDarkTheme ? 0.2 : 0.1),
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
                  child: const Text('Add as dev'), onTap: widget.onAddAsDev),
              HSeparators.xSmall(),
              const Text('•'),
              HSeparators.xSmall(),
              InkWell(child: const Text('Add'), onTap: widget.onAdd),
            ]
          ],
        ),
      ),
    );
  }
}
