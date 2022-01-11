// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manager/meta/views/tabs/sections/pub/models/pkg_data.dart';

// 🌎 Project imports:
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
  final List<PkgViewData> _pubPackages = <PkgViewData>[];

  bool _errorPage = false;
  bool _loadingPackages = true;

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
      _loadingPackages = true;
    });

    // ignore: unawaited_futures
    Future<void>.delayed(const Duration(seconds: 5)).then((_) {
      if (_loadingPackages) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          snackBarTile(
            context,
            'Loading your packages and polishing experience... Hold tight!',
            type: SnackBarType.done,
          ),
        );
      }
    });

    GetPkgResponseModel _result = await PkgViewData.getInitialPackages();

    switch (_result.response) {
      case GetPkgResponse.done:
        setState(() => _pubPackages.addAll(_result.packages));
        break;
      case GetPkgResponse.error:
        setState(() {
          _errorPage = true;
          _pubPackages.clear();
        });
        break;
      case GetPkgResponse.network:
        setState(() {
          _errorPage = false;
          _pubPackages.clear();
        });
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          snackBarTile(
            context,
            'There appears to be a problem with the network. Please check your connection try again.',
            type: SnackBarType.error,
          ),
        );
        break;
    }

    setState(() => _loadingPackages = false);
  }

  @override
  void initState() {
    _getInitialPackages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
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
                    const Text(
                      'Something went wrong. Maybe check your internet connection and try again.',
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
        else if (_loadingPackages)
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: <Widget>[
                    VSeparators.large(),
                    HorizontalAxisView(
                      title: 'Favorites & Popular Packages',
                      isVertical: true,
                      // Creates a empty list of packages that will be filled later.
                      content: <int>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
                          .map((int e) => const PubPkgTile(data: null))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          )
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
                      content: _pubPackages
                          .map((PkgViewData e) => PubPkgTile(data: e))
                          .toList(),
                    ),
                    VSeparators.large(),
                    RoundContainer(
                      borderWith: 2,
                      padding: const EdgeInsets.all(20),
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
    );
  }
}
