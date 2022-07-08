// 🎯 Dart imports:
import 'dart:isolate';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/theme.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:path_provider/path_provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/views/tabs/components/bg_loading_indicator.dart';
import 'package:fluttermatic/meta/views/tabs/components/horizontal_axis.dart';
import 'package:fluttermatic/meta/views/tabs/sections/pub/elements/pub_tile.dart';
import 'package:fluttermatic/meta/views/tabs/sections/pub/models/pkg_data.dart';

class HomePubSection extends StatefulWidget {
  const HomePubSection({Key? key}) : super(key: key);

  @override
  _HomePubSectionState createState() => _HomePubSectionState();
}

class _HomePubSectionState extends State<HomePubSection> {
  // Utils
  bool _errorPage = false;
  bool _loadingPackages = true;
  bool _loadPubCalled = false;
  bool _reloadingFromCache = false;

  // Data
  final List<PkgViewData> _pubPackages = <PkgViewData>[];
  final ReceivePort _loadPubPackagesPort =
      ReceivePort('GET_PUB_PACKAGES_ISOLATE_PORT');

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
      if (_loadingPackages && mounted) {
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

    // We want to get the pub cache first to show in the meantime as we are
    // making a request to the pub API to fetch the latest data.
    Isolate i = await Isolate.spawn(
      PkgViewData.getPackagesIsolate,
      <dynamic>[
        _loadPubPackagesPort.sendPort,
        (await getApplicationSupportDirectory()).path,
      ],
    ).timeout(const Duration(minutes: 2)).onError((_, StackTrace s) async {
      await logger.file(LogTypeTag.error, 'Failed to get packages: $_',
          stackTraces: s);

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          snackBarTile(context, 'Couldn\'t get the pub packages.',
              type: SnackBarType.error),
        );
      }

      return Isolate.current;
    });

    if (!_loadPubCalled) {
      _loadPubPackagesPort.listen((dynamic message) {
        if (mounted) {
          setState(() => _loadPubCalled = true);
          if (message is List && mounted) {
            setState(() {
              _loadingPackages = false;
              switch ((message.first as GetPkgResponseModel).response) {
                case GetPkgResponse.done:
                  _pubPackages.clear();
                  _pubPackages
                      .addAll((message.first as GetPkgResponseModel).packages);
                  break;
                case GetPkgResponse.error:
                  _errorPage = true;
                  _pubPackages.clear();
                  break;
                case GetPkgResponse.pending:
                  _pubPackages.clear();
                  _pubPackages
                      .addAll((message.first as GetPkgResponseModel).packages);
                  _reloadingFromCache = true;
                  break;
                case GetPkgResponse.network:
                  _errorPage = false;
                  _pubPackages.clear();
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
              _reloadingFromCache = message[2] == true;
            });

            // No more expected responses, we will kill the isolate.
            if (message[1] == true) {
              i.kill();
            }
          }
        }
      });
    }
  }

  @override
  void initState() {
    _getInitialPackages();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
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
                          onPressed: _getInitialPackages,
                          child: const Text('Retry'),
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
                    child: HorizontalAxisView(
                      title: 'Favorites & Popular Packages',
                      isVertical: true,
                      // Creates a empty list of packages that will be filled later.
                      content: <int>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
                          .map((int e) => const PubPkgTile(data: null))
                          .toList(),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
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
                              Consumer(builder: (_, ref, __) {
                                ThemeState themeState =
                                    ref.watch(themeStateController);

                                return SvgPicture.asset(
                                  Assets.package,
                                  height: 25,
                                  color: themeState.isDarkTheme
                                      ? Colors.white
                                      : Colors.black,
                                );
                              }),
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
        ),
        if (_reloadingFromCache)
          const Positioned(
            bottom: 20,
            right: 20,
            child: BgLoadingIndicator('Searching for Pub packages...'),
          ),
      ],
    );
  }
}
