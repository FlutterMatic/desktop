// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:pub_api_client/pub_api_client.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/load_activity_msg.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/general/extract_pubspec.dart';

class ScanProjectOutdatedDependenciesDialog extends StatefulWidget {
  final String pubspecPath;

  const ScanProjectOutdatedDependenciesDialog(
      {Key? key, required this.pubspecPath})
      : super(key: key);

  @override
  _ScanProjectOutdatedDependenciesDialogState createState() =>
      _ScanProjectOutdatedDependenciesDialogState();
}

class _ScanProjectOutdatedDependenciesDialogState
    extends State<ScanProjectOutdatedDependenciesDialog> {
  // Utils
  bool _isLoading = true;
  String _activityMessage = '';

  int _totalChecked = 0;
  int _totalAvailable = 0;

  // Dependencies that are outdated and their indexes.

  //... Regular dependencies.
  final List<_OutdatedPackageModel> _oldDependencies =
      <_OutdatedPackageModel>[];

  //... Dev dependencies.
  final List<_OutdatedPackageModel> _oldDevDependencies =
      <_OutdatedPackageModel>[];

  // Services
  final PubClient _pubClient = PubClient();

  /// Will scan the pubspec.yaml file and search to find any outdated
  /// dependency then add it to the respective list of outdated dependencies.
  Future<void> _loadOutdated() async {
    try {
      File pubspec = File(widget.pubspecPath);

      // Make sure that the pubspec.yaml file exists. If it doesn't, then we will
      // log a warning, inform the user and exit this package back to the
      // previous page.
      if (!await pubspec.exists()) {
        await logger.file(LogTypeTag.warning,
            'Pubspec file not found to check outdated dependencies.');

        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(snackBarTile(context,
              'Couldn\'t find the pubspec.yaml file for this project. Please refresh your projects list.'));
          Navigator.pop(context);
        }
        return;
      }

      List<String> pubspecLines = await pubspec.readAsLines();

      // Extracts the pubspec.yaml file so we can access its attributes.
      PubspecInfo pubspecInfo =
          extractPubspec(lines: pubspecLines, path: widget.pubspecPath);

      setState(() {
        _totalAvailable = (pubspecInfo.dependencies.length +
            pubspecInfo.devDependencies.length);
      });

      // Get the outdated dependencies.
      _oldDependencies.addAll(await _getDepInfo(
          pubspecLines: pubspecLines, packages: pubspecInfo.dependencies));

      // Get the outdated dev dependencies.
      _oldDevDependencies.addAll(await _getDepInfo(
          pubspecLines: pubspecLines, packages: pubspecInfo.devDependencies));

      _pubClient.close();

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (_, s) {
      await logger.file(LogTypeTag.error,
          'Failed to fetch the outdated dependencies for a pubspec.yaml file: $_',
          stackTraces: s);

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
          context,
          'Failed to get the outdated dependencies. Please try again later.',
          type: SnackBarType.error,
        ));

        Navigator.pop(context);
      }
    }
  }

  /// Gets and returns a list of the outdated packages from a list of packages
  /// you provide which you get by extracting any pubspec.yaml file.
  Future<List<_OutdatedPackageModel>> _getDepInfo({
    required List<String> pubspecLines,
    required List<DependenciesInfo> packages,
  }) async {
    List<_OutdatedPackageModel> outdatedDependencies =
        <_OutdatedPackageModel>[];

    // Gets the index of which line the provided package is declared in the
    // pubspec.yaml file.
    int _getPackageDeclarationLineIndex(String pkgName) {
      for (int i = 0; i < pubspecLines.length; i++) {
        if (pubspecLines[i].trim().startsWith('$pkgName: ')) {
          return i;
        }
      }

      return -1;
    }

    // Check all the outdated dependencies and adds the outdated ones to the
    // list of outdated dependencies along with the latest version and the
    // index of the line of that package in the pubspec.yaml file.
    for (int i = 0; i < packages.length; i++) {
      setState(() => _activityMessage =
          'Checking ${packages[i].name} from${packages[i].isDev ? ' dev' : ''} dependencies...');
      try {
        // Gets the version of the package declared in the pubspec.yaml file for
        // the project.
        String currentVersion = packages[i].version.replaceAll('^', '');

        // Get the package information from the Pub api. This will always have the
        // latest package information.
        PubPackage info = await _pubClient.packageInfo(packages[i].name);

        // If the package pubspec declared version is not equal to the latest
        // version from the Pub api, that means that the package is outdated.
        if (currentVersion != info.latest.version) {
          String name = packages[i].name;

          outdatedDependencies.add(
            _OutdatedPackageModel(
              pkgName: name,
              latestVersion: '^${info.latest.version}',
              index: _getPackageDeclarationLineIndex(name),
            ),
          );
        }
      } catch (_) {
        // If the package is not found, then we will log a warning and continue
        // with the next package.
        await logger.file(LogTypeTag.warning,
            'Could not find the package ${packages[i].name} in the pubspec.yaml file.');
        continue;
      }

      setState(() => _totalChecked++);
    }

    return outdatedDependencies;
  }

  /// Will update the pubspec.yaml file with the new dependency.
  Future<void> _updatePubspecDependency(
      List<_OutdatedPackageModel> dependencies) async {
    try {
      File pubspec = File(widget.pubspecPath);

      // We don't need to check if it exists because we already checked it
      // before.
      List<String> pubspecLines = await pubspec.readAsLines();

      // Iterate over the list of outdated packages and replace the list of the
      // lines of pubspec.yaml file. We will then write those new set of lines
      // as the new pubspec.yaml file.
      for (int i = 0; i < dependencies.length; i++) {
        // Replace the index of that file with the new package info.
        pubspecLines.removeAt(dependencies[i].index);
        pubspecLines.insert(
            dependencies[i].index,
            '${' ' * 2}${dependencies[i].pkgName}: ${dependencies[i].latestVersion}');
      }

      // Write the new pubspec.yaml file.
      await pubspec.writeAsString(pubspecLines.join('\n'));
      return;
    } catch (_) {
      await logger.file(LogTypeTag.warning,
          'Failed to update dependency $dependencies in the pubspec.yaml file.');
      return;
    }
  }

  @override
  void initState() {
    _loadOutdated();
    super.initState();
  }

  @override
  void dispose() {
    _pubClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          const DialogHeader(title: 'Scan pubspec.yaml'),
          if (_isLoading) ...<Widget>[
            LoadActivityMessageElement(
                message:
                    '$_totalChecked - $_totalAvailable $_activityMessage')
          ] else ...<Widget>[
            if (_oldDependencies.isEmpty && _oldDevDependencies.isEmpty)
              informationWidget(
                'There are no outdated dependencies found in this project, cheers!',
                type: InformationType.green,
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: SingleChildScrollView(
                  child: RoundContainer(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (_oldDependencies.isNotEmpty ||
                            _oldDevDependencies.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: informationWidget(
                              'Please be aware that there might be some dependencies conflicts that you may experience. In that case, please try to solve it by downgrading whichever dependency is relying on an older version.',
                            ),
                          ),
                        const Text('Outdated dependencies'),
                        VSeparators.xSmall(),
                        if (_oldDependencies.isNotEmpty) ...<Widget>[
                          Text(
                              '${_oldDependencies.length} ${_oldDependencies.length == 1 ? 'dependency' : 'dependencies'}',
                              style: const TextStyle(color: Colors.grey)),
                          VSeparators.small(),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Wrap(
                                  spacing: 5,
                                  runSpacing: 5,
                                  children: _oldDependencies
                                      .map((_OutdatedPackageModel e) =>
                                          _DependencyTile(name: e.pkgName))
                                      .toList(),
                                ),
                              ),
                              HSeparators.normal(),
                              SquareButton(
                                tooltip: 'Upgrade All',
                                color: Colors.transparent,
                                icon: const Icon(Icons.download_rounded,
                                    size: 15),
                                onPressed: () async {
                                  await _updatePubspecDependency(
                                      _oldDependencies);
                                  setState(_oldDependencies.clear);
                                },
                              ),
                            ],
                          ),
                        ] else
                          const Text('None - All are up to date.'),
                        VSeparators.small(),
                        RoundContainer(
                          height: 2,
                          width: double.infinity,
                          padding: EdgeInsets.zero,
                          color: Colors.blueGrey.withOpacity(0.4),
                          child: const SizedBox.shrink(),
                        ),
                        VSeparators.small(),
                        const Text('Outdated dev dependencies'),
                        VSeparators.xSmall(),
                        if (_oldDevDependencies.isNotEmpty) ...<Widget>[
                          Text(
                              '${_oldDevDependencies.length} ${_oldDevDependencies.length == 1 ? 'dependency' : 'dependencies'}',
                              style: const TextStyle(color: Colors.grey)),
                          VSeparators.small(),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Wrap(
                                  spacing: 5,
                                  runSpacing: 5,
                                  children: _oldDevDependencies
                                      .map((_OutdatedPackageModel e) =>
                                          _DependencyTile(name: e.pkgName))
                                      .toList(),
                                ),
                              ),
                              HSeparators.normal(),
                              SquareButton(
                                tooltip: 'Upgrade All',
                                color: Colors.transparent,
                                icon: const Icon(Icons.download_rounded,
                                    size: 15),
                                onPressed: () async {
                                  await _updatePubspecDependency(
                                      _oldDevDependencies);
                                  setState(_oldDevDependencies.clear);
                                },
                              ),
                            ],
                          ),
                        ] else
                          const Text('None - All are up to date.'),
                      ],
                    ),
                  ),
                ),
              ),
          ],
          VSeparators.normal(),
          RectangleButton(
            width: double.infinity,
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _DependencyTile extends StatelessWidget {
  final String name;

  const _DependencyTile({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RoundContainer(
      child: Text(name),
    );
  }
}

class _OutdatedPackageModel {
  final String pkgName;
  final String latestVersion;
  final int index;

  const _OutdatedPackageModel({
    required this.pkgName,
    required this.latestVersion,
    required this.index,
  });
}
