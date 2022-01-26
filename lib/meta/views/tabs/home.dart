// 🎯 Dart imports:
import 'dart:io';
import 'dart:isolate';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttermatic/meta/utils/check_new_version.dart';
import 'package:fluttermatic/meta/utils/clear_old_logs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/dialog_templates/settings/settings.dart';
import 'package:fluttermatic/core/libraries/notifiers.dart';
import 'package:fluttermatic/core/libraries/services.dart';
import 'package:fluttermatic/core/libraries/views.dart';
import 'package:fluttermatic/core/libraries/widgets.dart';
import 'package:fluttermatic/meta/views/dialogs/update_fluttermatic.dart';
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
  // Isolate Receive Ports
  static final ReceivePort _clearLogsPort = ReceivePort('CLEAR_OLD_LOGS_PORT');
  static final ReceivePort _checkUpdatesPort =
      ReceivePort('CHECK_UPDATES_PORT');

  // Utils
  bool _animateFinish = false;
  bool _isUpdatesPortListening = false;
  bool _isClearLogsPortListening = false;

  // Update Status
  String? _updateDownloadUrl;
  bool _updateAvailable = false;

  // Tabs
  late HomeTabObject _selectedTab;

  late final List<HomeTabObject> _tabs = const <HomeTabObject>[
    HomeTabObject('Home', Assets.home, HomeMainSection()),
    HomeTabObject('Projects', Assets.project, HomeProjectsSection()),
    HomeTabObject('Pub Packages', Assets.package, HomePubSection()),
    if (!kReleaseMode) // TODO: Remove this once this tab is ready for production.
      HomeTabObject('Workflows', Assets.workflow, HomeWorkflowSections()),
  ];

  Future<void> _checkUpdates() async {
    try {
      while (mounted) {
        if (!context.read<ConnectionNotifier>().isOnline) {
          await Future<void>.delayed(const Duration(seconds: 5));
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
            context,
            'Please check your network connection to use FlutterMatic at its best.',
            type: SnackBarType.warning,
          ));

          await logger.file(LogTypeTag.warning,
              'FlutterMatic is not online. Couldn\'t check for updates.');

          await Future<void>.delayed(const Duration(minutes: 5));
          continue;
        }

        await Isolate.spawn(checkNewFlutterMaticVersion, <dynamic>[
          _checkUpdatesPort.sendPort,
          (await getApplicationSupportDirectory()).path,
          Platform.operatingSystem.toLowerCase()
        ]);

        if (!_isUpdatesPortListening && mounted) {
          setState(() => _isUpdatesPortListening = true);
          _checkUpdatesPort.listen((dynamic message) {
            setState(() {
              _updateAvailable = message[0];
              _updateDownloadUrl = message[1];
            });
          });
        }

        // Keep checking for new updates every hour.
        await Future<void>.delayed(const Duration(hours: 1));
      }
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Couldn\'t check for updates: $_',
          stackTraces: s);
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          snackBarTile(
            context,
            'We couldn\'t check for updates. Perhaps check your network connection. If not, then please try again later or check for any new release manually on GitHub.',
            type: SnackBarType.error,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    setState(() {
      if (widget.index != null) {
        _selectedTab = _tabs[widget.index!];
      } else {
        _selectedTab = _tabs.first;
      }
    });
    Future<void>.delayed(const Duration(milliseconds: 500), () async {
      setState(() => _animateFinish = true);
    });
    _checkUpdates();
    // After a minute when everything has settled, we will clear logs that are
    // old to avoid clogging up the FlutterMatic app data space.
    Future<void>.delayed(const Duration(seconds: 5)).then((_) async {
      await Isolate.spawn(clearOldLogs, <dynamic>[
        _clearLogsPort.sendPort,
        (await getApplicationSupportDirectory()).path
      ]);

      if (!_isClearLogsPortListening) {
        setState(() => _isClearLogsPortListening = true);
        _clearLogsPort.listen((_) => _clearLogsPort.close());
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              AnimatedOpacity(
                opacity: _animateFinish ? 1 : 0.1,
                duration: const Duration(milliseconds: 300),
                child: SizedBox(
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
                                onPressed: () =>
                                    setState(() => _selectedTab = e),
                                selected: _selectedTab == e,
                              );
                            },
                          ),
                          const Spacer(),
                          // Short view
                          if (_showShortView)
                            Column(
                              children: <Widget>[
                                if (_updateAvailable)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: UpdateAppButton(
                                        downloadUrl: _updateDownloadUrl),
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
                                if (_updateAvailable)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, bottom: 10),
                                    child: UpdateAppButton(
                                        downloadUrl: _updateDownloadUrl),
                                  ),
                              ],
                            ),
                        ],
                      ),
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
                    AnimatedOpacity(
                      opacity: _animateFinish ? 1 : 0.1,
                      duration: const Duration(milliseconds: 300),
                      child: const HomeSearchComponent(),
                    ),
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

Widget _tabTile(
  BuildContext context, {
  required Widget icon,
  required String name,
  required Function() onPressed,
  required bool selected,
}) {
  ThemeData _customTheme = Theme.of(context);
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
            ? _customTheme.colorScheme.secondary.withOpacity(0.2)
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
                          color: _customTheme.textTheme.bodyText1!.color!
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

class HomeTabObject {
  final String name;
  final String icon;
  final Widget child;

  const HomeTabObject(this.name, this.icon, this.child);
}

class UpdateAppButton extends StatelessWidget {
  final String? downloadUrl;

  const UpdateAppButton({
    Key? key,
    required this.downloadUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Update FlutterMatic',
      waitDuration: const Duration(seconds: 1),
      child: RectangleButton(
        width: 40,
        height: 40,
        color: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: const Icon(Icons.download_rounded, color: kGreenColor),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => UpdateFlutterMaticDialog(downloadUrl: downloadUrl),
          );
        },
      ),
    );
  }
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
