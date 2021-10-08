// 🎯 Dart imports:
import 'dart:convert';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

// 🌎 Project imports:
import 'package:manager/core/libraries/components.dart';
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/core/libraries/utils.dart';
import 'package:manager/core/libraries/views.dart';
import 'package:manager/core/libraries/widgets.dart';

class HomePubSection extends StatefulWidget {
  const HomePubSection({Key? key}) : super(key: key);

  @override
  _HomePubSectionState createState() => _HomePubSectionState();
}

class _HomePubSectionState extends State<HomePubSection> {
  String _searchText = '';

  final FocusNode _searchNode = FocusNode();

  List<PubPackageObject> _searchResults = <PubPackageObject>[];

  List<dynamic> _pubs = <dynamic>[];

  bool _loadingSearch = false;

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
    setState(() => _loadingSearch = true);
    http.Response _result = await http.get(
      Uri.parse('https://pub.dev/api/package-name-completion-data'),
    );
    if (_result.statusCode == 200 && mounted) {
      dynamic _packages = json.decode(_result.body)['packages'];
      setState(() => _pubs = _packages);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        snackBarTile(
          context,
          'We couldn\'t fetch the pub packages. Please make sure you have an internet connection and try again.',
          type: SnackBarType.error,
        ),
      );
    }
    setState(() => _loadingSearch = false);
  }

  // We do not need to make a request to the pub API because this won't be
  // called every time the user types.
  // We will filter out the [_pub] list and set the results to the
  // [_searchResults].
  Future<void> _updateResults() async {
    if (_pubs.isEmpty) {
      await _getInitialPackages();
    }
    if (_searchText.isEmpty) {
      setState(() => _searchResults = <PubPackageObject>[]);
      return;
    }

    // The total results for the current search. This shouldn't be greater than
    // the [_maxResults].
    int _resultsCount = 0;

    // The maximum search results to show at a time.
    int _maxResults = 5;

    // Filters the results based on the [_searchText].
    List<dynamic> _flexResults = _pubs.where((dynamic e) {
      String _name = e.toString().replaceAll('_', '');

      // Filters the pub packages down to the user search.
      bool _hasMatch() {
        if (_name.toLowerCase().contains(_searchText.toLowerCase().replaceAll(' ', '').replaceAll('_', ''))) {
          return true;
        } else {
          return false;
        }
      }

      // Returns true of false depending on if the package name matches.
      if (_resultsCount < _maxResults && _hasMatch()) {
        _resultsCount++;
        return true;
      } else {
        return false;
      }
    }).toList();

    // Sets the results of no more than [_maxResults] to the [_searchResults].
    setState(() => _searchResults = _flexResults.map((dynamic e) => PubPackageObject(name: e.toString())).toList());
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
                      const SizedBox(width: (40 * _buttonsOnRight) + ((_buttonsOnRight - 1) * 10)),
                    const Spacer(),
                    SizedBox(
                      width: (MediaQuery.of(context).size.width > 1000) ? 500 : 400,
                      height: 40,
                      child: RoundContainer(
                        padding: EdgeInsets.zero,
                        borderColor: Colors.blueGrey.withOpacity(0.2),
                        child: Center(
                          child: Padding(
                            padding:
                                EdgeInsets.only(left: 8, right: _searchText == '' || !_searchNode.hasFocus ? 8 : 5),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    focusNode: _searchNode,
                                    style: TextStyle(
                                      color: (Theme.of(context).isDarkTheme ? Colors.white : Colors.black)
                                          .withOpacity(0.8),
                                    ),
                                    cursorRadius: const Radius.circular(5),
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(
                                        color: (Theme.of(context).isDarkTheme ? Colors.white : Colors.black)
                                            .withOpacity(0.6),
                                        fontSize: 14,
                                      ),
                                      hintText: 'Search Packages',
                                      border: InputBorder.none,
                                      isCollapsed: true,
                                    ),
                                    onFieldSubmitted: (String? val) {
                                      // Show a page with all the results.
                                    },
                                    onChanged: (String val) {
                                      if (val.isEmpty) {
                                        setState(() {
                                          _searchText = val;
                                          _searchResults = <PubPackageObject>[];
                                        });
                                      } else {
                                        setState(() => _searchText = val);
                                        _updateResults();
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
                                      color: Theme.of(context).isDarkTheme ? Colors.white : Colors.black,
                                    ),
                                    onPressed: () {
                                      _searchNode.unfocus();
                                      setState(() {
                                        _searchResults = <PubPackageObject>[];
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
                        color: Theme.of(context).isDarkTheme ? Colors.white : Colors.black,
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
                        color: Theme.of(context).isDarkTheme ? Colors.white : Colors.black,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            VSeparators.small(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      VSeparators.large(),
                      const HorizontalAxisView(
                        title: 'Flutter Favorites',
                        content: <Widget>[
                          PubFavoriteTile(),
                          PubFavoriteTile(),
                          PubFavoriteTile(),
                          PubFavoriteTile(),
                          PubFavoriteTile(),
                          PubFavoriteTile(),
                        ],
                      ),
                      VSeparators.large(),
                      const HorizontalAxisView(
                        title: 'Popular Packages',
                        content: <Widget>[
                          PubFavoriteTile(),
                          PubFavoriteTile(),
                          PubFavoriteTile(),
                          PubFavoriteTile(),
                          PubFavoriteTile(),
                          PubFavoriteTile(),
                        ],
                      ),
                      VSeparators.large(),
                      const HorizontalAxisView(
                        isVertical: true,
                        title: 'Suggested Packages',
                        content: <Widget>[
                          PubFavoriteTile(),
                          PubFavoriteTile(),
                          PubFavoriteTile(),
                          PubFavoriteTile(),
                          PubFavoriteTile(),
                          PubFavoriteTile(),
                        ],
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
                              color: Theme.of(context).isDarkTheme ? Colors.white : Colors.black,
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
                                  color: Theme.of(context).isDarkTheme ? Colors.white : Colors.black,
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
        if (_searchText != '')
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500, maxHeight: 300),
                decoration: BoxDecoration(
                  color: Theme.of(context).isDarkTheme ? const Color(0xff262F34) : Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Colors.blueGrey.withOpacity(0.4),
                  ),
                ),
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  child: Builder(
                    builder: (BuildContext context) {
                      if (_searchResults.isEmpty && _loadingSearch) {
                        return const CustomLinearProgressIndicator();
                      } else if (_searchResults.isEmpty && !_loadingSearch) {
                        return informationWidget(
                          'There are no results for your search query. Try using another term instead.',
                          type: InformationType.error,
                        );
                      } else {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: _searchResults.map((PubPackageObject e) {
                            double _pad = _searchResults.indexOf(e) == _searchResults.length - 1 ? 0 : 5;
                            return Padding(
                              padding: EdgeInsets.only(bottom: _pad),
                              child: PubPackageSearchResultTile(package: e),
                            );
                          }).toList(),
                        );
                      }
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
