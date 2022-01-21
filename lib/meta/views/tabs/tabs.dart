// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/dialog_templates/settings/settings.dart';
import 'package:fluttermatic/core/libraries/notifiers.dart';
import 'package:fluttermatic/core/libraries/views.dart';
import 'package:fluttermatic/core/libraries/widgets.dart';
import 'package:fluttermatic/meta/views/tabs/search.dart';
import 'package:fluttermatic/meta/views/tabs/sections/home/home.dart';
import 'package:fluttermatic/meta/views/tabs/sections/workflows/workflow.dart';

class HomeScreen extends StatefulWidget {
  final int? index;
  const HomeScreen({Key? key, this.index}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeTabObject _selectedTab;

  late final List<HomeTabObject> _tabs = const <HomeTabObject>[
    HomeTabObject('Home', Assets.home, HomeMainSection()),
    HomeTabObject('Projects', Assets.project, HomeProjectsSection()),
    HomeTabObject('Pub Packages', Assets.package, HomePubSection()),
    HomeTabObject('Workflows', Assets.workflow, HomeWorkflowSections()),
  ];

  @override
  void initState() {
    setState(() {
      if (widget.index != null) {
        _selectedTab = _tabs[widget.index!];
      } else {
        _selectedTab = _tabs.first;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    Size _size = MediaQuery.of(context).size;

    bool _showShortView = _size.width < 900;
    return SafeArea(
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: _showShortView ? 50 : 230,
                child: ColoredBox(
                  color: Colors.blueGrey.withOpacity(0.08),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _showShortView ? 5 : 15,
                      vertical: _showShortView ? 5 : 20,
                    ),
                    child: Column(
                      children: <Widget>[
                        ..._tabs.map(
                          (HomeTabObject e) {
                            return _tabTile(
                              context,
                              icon: SvgPicture.asset(
                                e.icon,
                                color: context
                                        .read<ThemeChangeNotifier>()
                                        .isDarkTheme
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              name: e.name,
                              onPressed: () => setState(() => _selectedTab = e),
                              selected: _selectedTab == e,
                            );
                          },
                        ),
                        const Spacer(),
                        // Short view
                        if (_size.width < 900)
                          Column(
                            children: <Widget>[
                              if (isNewVersionAvailable)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _updateAppButton(context, customTheme),
                                ),
                              _tabTile(
                                context,
                                icon: SvgPicture.asset(
                                  Assets.settings,
                                  color: context
                                          .read<ThemeChangeNotifier>()
                                          .isDarkTheme
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                name: 'Settings',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => const SettingDialog(),
                                  );
                                },
                                selected: false,
                              ),
                            ],
                          )
                        else
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: _tabTile(
                                  context,
                                  icon: SvgPicture.asset(
                                    Assets.settings,
                                    color: context
                                            .read<ThemeChangeNotifier>()
                                            .isDarkTheme
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  name: 'Settings',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => const SettingDialog(),
                                    );
                                  },
                                  selected: false,
                                ),
                              ),
                              if (isNewVersionAvailable)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, bottom: 10),
                                  child: _updateAppButton(context, customTheme),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: _selectedTab.child,
                    ),
                    const HomeSearchComponent(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeTabObject {
  final String name;
  final String icon;
  final Widget child;

  const HomeTabObject(this.name, this.icon, this.child);
}

Widget _tabTile(
  BuildContext context, {
  required Widget icon,
  required String name,
  required Function() onPressed,
  required bool selected,
}) {
  ThemeData customTheme = Theme.of(context);
  Size _size = MediaQuery.of(context).size;

  bool _showShortView = _size.width < 900;
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Tooltip(
      message: _showShortView ? name : '',
      waitDuration: const Duration(seconds: 1),
      child: RectangleButton(
        width: 200,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        color: selected
            ? customTheme.colorScheme.secondary.withOpacity(0.2)
            : Colors.transparent,
        padding: EdgeInsets.all(_showShortView ? 5 : 10),
        onPressed: onPressed,
        child: Align(
          alignment: Alignment.centerLeft,
          child: !_showShortView
              ? Row(
                  children: <Widget>[
                    icon,
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        name,
                        style: TextStyle(
                          color: customTheme.textTheme.bodyText1!.color!
                              .withOpacity(selected ? 1 : .4),
                        ),
                      ),
                    ),
                  ],
                )
              : Center(child: icon),
        ),
      ),
    ),
  );
}

Widget _updateAppButton(BuildContext context, ThemeData theme) {
  return RectangleButton(
    width: 40,
    height: 40,
    hoverColor: Colors.transparent,
    focusColor: Colors.transparent,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    color: theme.colorScheme.secondary.withOpacity(0.2),
    child: const Icon(Icons.download_rounded),
    onPressed: () {
      ScaffoldMessenger.of(context).clearSnackBars();
      // TODO(@ZiyadF296): Show update FlutterMatic dialog
      ScaffoldMessenger.of(context).showSnackBar(
        snackBarTile(
          context,
          'There is a new version of FlutterMatic ready to be installed on your device.',
          type: SnackBarType.warning,
        ),
      );
    },
  );
}

// // We do not need to make a request to the pub API because this won't be
// // called every time the user types.
// // We will filter out the [_pub] list and set the results to the
// // [_searchResults].
// Future<void> _startSearch() async {
//   int _max = 5;

//   setState(() {
//     _loadingSearch = true;
//     _searchResults.clear();
//   });
//   if (_fastSearch) {
//     if (_pubs.isEmpty) {
//       await _getInitialPackages();
//     }

//     if (_searchText.isEmpty) {
//       setState(_searchResults.clear);
//       return;
//     }
//     // The total results for the current search. This shouldn't be greater than
//     // the [_maxResults].
//     int _resultsCount = 0;

//     // Filters the results based on the [_searchText].
//     List<dynamic> _flexResults = _pubs.where((dynamic e) {
//       String _name = e.toString().replaceAll('_', '');

//       // Filters the pub packages down to the user search.
//       bool _hasMatch() {
//         if (_name.toLowerCase().contains(_searchText
//             .toLowerCase()
//             .replaceAll(' ', '')
//             .replaceAll('_', ''))) {
//           return true;
//         } else {
//           return false;
//         }
//       }

//       // Returns true of false depending on if the package name matches.
//       if (_resultsCount < _max && _hasMatch()) {
//         _resultsCount++;
//         return true;
//       } else {
//         return false;
//       }
//     }).toList();

//     // Sets the results of no more than [_maxResults] to the [_searchResults].
//     setState(() => _searchResults.addAll(_flexResults
//         .map((dynamic e) => PubPackageObject(name: e.toString()))
//         .toList()));
//   } else {
//     if (_searchText.isEmpty) {
//       setState(_searchResults.clear);
//       return;
//     }

//     List<String> _flexResults = <String>[];

//     // TODO: Consider isolating this task to avoid clogging UI.
//     await PubClient().search(_searchText).then((_) =>
//         _flexResults.addAll(_.packages.map((PackageResult e) => e.package)));

//     // Sets the results of no more than [_maxResults] to the [_searchResults].
//     setState(() => _searchResults.addAll(_flexResults
//         .sublist(0, _flexResults.length > _max ? _max : _flexResults.length)
//         .map((dynamic e) => PubPackageObject(name: e.toString()))
//         .toList()));
//   }

//   setState(() => _loadingSearch = false);
// }

  // Future<void> _startSearch() async {
  //   setState(() => _loadingSearch = true);

  //   List<ProjectObject> _results = <ProjectObject>[];

  //   if (_searchText.isEmpty) {
  //     setState(_searchResults.clear);
  //     return;
  //   }

  //   String _q = removeSpaces(_searchText.toLowerCase());

  //   for (ProjectObject _project in _projects) {
  //     if (_results.length >= 5) {
  //       break;
  //     }

  //     List<bool> _matches = <bool>[
  //       removeSpaces(_project.name.toLowerCase()).contains(_q),
  //       _project.path.toLowerCase().contains(_q),
  //       if (_project.description != null)
  //         removeSpaces(_project.description!.toLowerCase()).contains(_q),
  //     ];

  //     if (_matches.contains(true)) {
  //       _results.add(_project);
  //     }
  //   }

  //   setState(() {
  //     _searchResults.clear();
  //     _searchResults.addAll(_results);
  //     _loadingSearch = false;
  //   });
  // }
