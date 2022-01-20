// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:file_selector/file_selector.dart' as file_selector;

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/app/constants/shared_pref.dart';
import 'package:fluttermatic/core/libraries/widgets.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/shared_pref.dart';

class ProjectsSettingsSection extends StatefulWidget {
  const ProjectsSettingsSection({Key? key}) : super(key: key);

  @override
  _ProjectsSettingsSectionState createState() =>
      _ProjectsSettingsSectionState();
}

class _ProjectsSettingsSectionState extends State<ProjectsSettingsSection> {
  // User Inputs
  String? _dirPath;
  bool _dirPathError = false;

  int _refreshIntervals = 1;

  Future<void> _getProjectPath() async {
    if (SharedPref().pref.containsKey(SPConst.projectsPath)) {
      setState(
          () => _dirPath = SharedPref().pref.getString(SPConst.projectsPath));
    } else {
      setState(() => _dirPathError = true);
    }
  }

  Future<void> _getProjectRefreshIntervals() async {
    if (SharedPref().pref.containsKey(SPConst.projectRefresh)) {
      setState(() => _refreshIntervals =
          SharedPref().pref.getInt(SPConst.projectRefresh) ?? 1);
    } else {
      await SharedPref().pref.setInt(SPConst.projectRefresh, 1);
    }
  }

  @override
  void initState() {
    _getProjectPath();
    _getProjectRefreshIntervals();
    super.initState();
  }

  @override
  void dispose() {
    _dirPathError = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return TabViewTabHeadline(
      title: 'Projects',
      content: <Widget>[
        if (_dirPathError)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: informationWidget(
              'Couldn\'t fetch your projects path. Try settings your projects path.',
              type: InformationType.error,
            ),
          ),
        RoundContainer(
          color: Colors.blueGrey.withOpacity(0.2),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  _dirPath ??
                      (_dirPathError
                          ? 'Couldn\'t fetch your projects path. Try settings your path'
                          : 'Fetching your preferred project directory'),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              ),
              if (_dirPath == null && !_dirPathError)
                const Spinner(size: 15, thickness: 2)
              else
                IconButton(
                  color: Colors.transparent,
                  icon: Icon(
                    Icons.edit_outlined,
                    color: customTheme.textTheme.bodyText1!.color,
                  ),
                  onPressed: () async {
                    String? _projectsDirectory;
                    String? _directoryPath =
                        await file_selector.getDirectoryPath(
                      initialDirectory: _projectsDirectory,
                      confirmButtonText: 'Confirm',
                    );
                    if (_directoryPath != null) {
                      setState(() {
                        _dirPathError = false;
                        _dirPath = _directoryPath;
                      });
                      await SharedPref()
                          .pref
                          .setString(SPConst.projectsPath, _directoryPath);

                      await logger.file(LogTypeTag.info,
                          'Projects path was set to: $_directoryPath');
                    } else {
                      await logger.file(
                          LogTypeTag.warning, 'Projects path was not chosen');
                    }
                  },
                ),
            ],
          ),
        ),
        VSeparators.large(),
        const Text('Refresh Options'),
        VSeparators.normal(),
        Row(
          children: <Widget>[
            const Expanded(
              child: Text(
                'How often should we refresh your projects list.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            HSeparators.normal(),
            PopupMenuButton<dynamic>(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: _refreshIntervals == 60
                    ? const Text('Every 1 hour')
                    : Text(
                        'Every $_refreshIntervals minute${_refreshIntervals > 1 ? 's' : ''}',
                      ),
              ),
              tooltip: '',
              itemBuilder: (_) {
                return <PopupMenuEntry<dynamic>>[
                  const PopupMenuItem<int>(value: 1, child: Text('1 minute')),
                  const PopupMenuItem<int>(value: 5, child: Text('5 minutes')),
                  const PopupMenuItem<int>(
                      value: 10, child: Text('10 minutes')),
                  const PopupMenuItem<int>(value: 60, child: Text('1 hour')),
                ];
              },
              onSelected: (dynamic val) async {
                try {
                  await SharedPref().pref.setInt(SPConst.projectRefresh, val);
                  await logger.file(LogTypeTag.info,
                      'Projects refresh intervals was set to: $val');
                  setState(() => _refreshIntervals = val);
                } catch (_, s) {
                  await logger.file(LogTypeTag.error,
                      'Couldn\'t set projects refresh interval: $_',
                      stackTraces: s);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    snackBarTile(
                      context,
                      'Couldn\'t update your project refresh intervals.',
                      type: SnackBarType.error,
                    ),
                  );
                }
              },
              initialValue: SharedPref().pref.getInt(SPConst.projectRefresh),
            )
          ],
        ),
        VSeparators.normal(),
      ],
    );
  }
}
