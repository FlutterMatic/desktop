// 🎯 Dart imports:
import 'dart:convert';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:pub_api_client/pub_api_client.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/shared_pref.dart';
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/core/libraries/utils.dart';
import 'package:manager/core/libraries/views.dart';
import 'package:manager/core/libraries/widgets.dart';

// void _applySearch(List<dynamic> info) {
//   String _search = info[0];
//   List<PubPackageObject> _packagesNames = info[1];
//   SendPort _sendPort = info[2];

//   List<PubPackageObject> _results = <PubPackageObject>[];

//   if (_search.isEmpty) {
//     _sendPort.send(_results);
//     return;
//   }

//   String _q = removeSpaces(_search.toLowerCase());

//   for (PubPackageObject _packages in _packagesNames) {
//     if (_results.length >= 5) {
//       break;
//     }

//     List<bool> _matches = <bool>[
//       removeSpaces(_packages.name.toLowerCase()).contains(_q),
//     ];

//     if (_matches.contains(true)) {
//       _results.add(_packages);
//     }
//   }

//   _sendPort.send(_results);
// }

class HomePubSection extends StatefulWidget {
  const HomePubSection({Key? key}) : super(key: key);

  @override
  _HomePubSectionState createState() => _HomePubSectionState();
}

class _HomePubSectionState extends State<HomePubSection> {
  String _searchText = '';

  final FocusNode _searchNode = FocusNode();

  final List<PubPackageObject> _searchResults = <PubPackageObject>[];
  final List<PubPackageObject> _pubFavorites = <PubPackageObject>[];

  List<dynamic> _pubs = <dynamic>[];

  bool _fastSearch = true;
  bool _loadingSearch = false;
  bool _loadedFlutterFavorites = false;
  bool _errorPage = false;

  static const int _buttonsOnRight = 2;

  // Will get the JSON from this URL: https://pub.dev/api/package-name-completion-data
  // This JSON will contain the list of all pub packages that are available.
  //
  // The results will only contain the package name.
  //
  // To get the full data about a specific package we need to make a request to
  // the following URL: https://pub.dev/api/packages/package-name
  //
  // Once we get the JSON, we will store it the first time and then use it to
  // filter the results as the user types.
  // This is done to avoid making too many requests to the pub API.
  Future<void> _getInitialPackages() async {
    setState(() {
      _errorPage = false;
      _loadingSearch = true;
      _fastSearch = SharedPref().pref.getBool(SPConst.pubFastSearch) ?? true;
    });
    http.Response _result = await http
        .get(Uri.parse('https://pub.dev/api/package-name-completion-data'))
        .onError((_, __) => http.Response('', 300));
    if (_result.statusCode == 200 && mounted) {
      dynamic _packages = json.decode(_result.body)['packages'];
      await PubClient().search('').then((SearchResults value) {
        if (mounted) {
          setState(() {
            _pubs = _packages;
            _pubFavorites.addAll(value.packages
                .map((PackageResult e) => PubPackageObject(name: e.package)));
            _loadedFlutterFavorites = true;
            _errorPage = false;
          });
        }
      });
    } else if (mounted) {
      if (_pubs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          snackBarTile(
            context,
            'We couldn\'t fetch the pub packages. Please make sure you have an internet connection and try again.',
            type: SnackBarType.error,
          ),
        );
      }

      setState(() {
        _pubs = <dynamic>[''];
        _errorPage = true;
      });
    }
    if (mounted) {
      setState(() => _loadingSearch = false);
    }
  }

  // We do not need to make a request to the pub API because this won't be
  // called every time the user types.
  // We will filter out the [_pub] list and set the results to the
  // [_searchResults].
  Future<void> _startSearch() async {
    int _max = 5;

    setState(() {
      _loadingSearch = true;
      _searchResults.clear();
    });
    if (_fastSearch) {
      if (_pubs.isEmpty) {
        await _getInitialPackages();
      }

      if (_searchText.isEmpty) {
        setState(_searchResults.clear);
        return;
      }
      // The total results for the current search. This shouldn't be greater than
      // the [_maxResults].
      int _resultsCount = 0;

      // Filters the results based on the [_searchText].
      List<dynamic> _flexResults = _pubs.where((dynamic e) {
        String _name = e.toString().replaceAll('_', '');

        // Filters the pub packages down to the user search.
        bool _hasMatch() {
          if (_name.toLowerCase().contains(_searchText
              .toLowerCase()
              .replaceAll(' ', '')
              .replaceAll('_', ''))) {
            return true;
          } else {
            return false;
          }
        }

        // Returns true of false depending on if the package name matches.
        if (_resultsCount < _max && _hasMatch()) {
          _resultsCount++;
          return true;
        } else {
          return false;
        }
      }).toList();

      // Sets the results of no more than [_maxResults] to the [_searchResults].
      setState(() => _searchResults.addAll(_flexResults
          .map((dynamic e) => PubPackageObject(name: e.toString()))
          .toList()));
    } else {
      if (_searchText.isEmpty) {
        setState(_searchResults.clear);
        return;
      }

      List<String> _flexResults = <String>[];

      // TODO: Consider isolating this task to avoid clogging UI.
      await PubClient().search(_searchText).then((_) =>
          _flexResults.addAll(_.packages.map((PackageResult e) => e.package)));

      // Sets the results of no more than [_maxResults] to the [_searchResults].
      setState(() => _searchResults.addAll(_flexResults
          .sublist(0, _flexResults.length > _max ? _max : _flexResults.length)
          .map((dynamic e) => PubPackageObject(name: e.toString()))
          .toList()));
    }

    setState(() => _loadingSearch = false);
  }

  @override
  void initState() {
    _getInitialPackages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                              ((_buttonsOnRight - 1) * 10)),
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
                                        color: (Theme.of(context).isDarkTheme
                                                ? Colors.white
                                                : Colors.black)
                                            .withOpacity(0.6),
                                        fontSize: 14,
                                      ),
                                      hintText: 'Search Packages',
                                      border: InputBorder.none,
                                      isCollapsed: true,
                                    ),
                                    onChanged: (String val) {
                                      if (val.isEmpty) {
                                        setState(() => _searchText = val);
                                        _startSearch();
                                      } else {
                                        setState(() => _searchText = val);
                                        _startSearch();
                                      }
                                    },
                                  ),
                                ),
                                HSeparators.xSmall(),
                                if (_searchText.isEmpty ||
                                    !_searchNode.hasFocus)
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
                                      _searchNode.unfocus();
                                      setState(() {
                                        _searchResults.clear();
                                        _searchText = '';
                                      });
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
                      child: Icon(
                        Icons.favorite_outline_rounded,
                        size: 13,
                        color: Theme.of(context).isDarkTheme
                            ? Colors.white
                            : Colors.black,
                      ),
                      onPressed: () {},
                    ),
                    HSeparators.small(),
                    RectangleButton(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 13,
                        color: Theme.of(context).isDarkTheme
                            ? Colors.white
                            : Colors.black,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            VSeparators.small(),
            if (_errorPage)
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SvgPicture.asset(Assets.error),
                        VSeparators.normal(),
                        Text(
                          'Hmm... Something went wrong',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: (Theme.of(context).isDarkTheme
                                    ? Colors.white
                                    : Colors.black)
                                .withOpacity(0.8),
                            fontSize: 20,
                          ),
                        ),
                        VSeparators.normal(),
                        const Text(
                          'Maybe check your internet connection and try again.',
                          textAlign: TextAlign.center,
                        ),
                        VSeparators.large(),
                        RectangleButton(
                          child: const Text('Retry'),
                          onPressed: _getInitialPackages,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (!_loadedFlutterFavorites)
              const Expanded(child: Center(child: Spinner(thickness: 2)))
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        VSeparators.large(),
                        HorizontalAxisView(
                          title: 'Favorites & Popular Packages',
                          isVertical: true,
                          content: _pubFavorites
                              .map((PubPackageObject e) =>
                                  PubPkgTile(name: e.name))
                              .toList(),
                        ),
                        VSeparators.large(),
                        RoundContainer(
                          borderWith: 2,
                          borderColor: Colors.blueGrey.withOpacity(0.2),
                          width: double.infinity,
                          child: Row(
                            children: <Widget>[
                              SvgPicture.asset(
                                Assets.package,
                                height: 25,
                                color: Theme.of(context).isDarkTheme
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              HSeparators.small(),
                              const Expanded(
                                child: Text(
                                  'Try searching for the package that you are looking for.',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              HSeparators.large(),
                              RectangleButton(
                                child: Text(
                                  'Search',
                                  style: TextStyle(
                                    color: Theme.of(context).isDarkTheme
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                onPressed: _searchNode.requestFocus,
                              ),
                            ],
                          ),
                        ),
                        VSeparators.large(),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        // Show the search results in realtime if the user has typed anything
        // to search for.
        if (_searchText.isNotEmpty)
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Container(
                constraints:
                    const BoxConstraints(maxWidth: 500, maxHeight: 300),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Builder(
                      builder: (BuildContext context) {
                        if (_searchResults.isEmpty && _loadingSearch) {
                          return const CustomLinearProgressIndicator();
                        } else if (_searchResults.isEmpty && !_loadingSearch) {
                          return informationWidget(
                            'There are no results for your search query. Try using another term instead.',
                            type: InformationType.error,
                          );
                        } else {
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: _searchResults.length > 5
                                ? 5
                                : _searchResults.length,
                            itemBuilder: (_, int i) {
                              double _pad;
                              if (i == _searchResults.length - 1) {
                                _pad = 0;
                              } else {
                                _pad = 5;
                              }
                              return Padding(
                                padding: EdgeInsets.only(bottom: _pad),
                                child: PubPackageSearchResultTile(
                                    package: _searchResults[i]),
                              );
                            },
                          );
                        }
                      },
                    ),
                    if (_searchResults.isNotEmpty && !_loadingSearch)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            const Text('Fast search'),
                            HSeparators.xSmall(),
                            Switch(
                              value: _fastSearch,
                              onChanged: (bool value) async {
                                setState(() => _fastSearch = value);
                                await SharedPref()
                                    .pref
                                    .setBool(SPConst.pubFastSearch, value);
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
