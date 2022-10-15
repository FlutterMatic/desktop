// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:file_selector/file_selector.dart' as file_selector;
import 'package:path_provider/path_provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/shared_pref.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/components/widgets/ui/spinner.dart';
import 'package:fluttermatic/components/widgets/ui/tab_view.dart';
import 'package:fluttermatic/core/notifiers/notifiers/actions/projects.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/general/shared_pref.dart';

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

  int _refreshIntervals = 60;

  void _getProjectPath() {
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
          SharedPref().pref.getInt(SPConst.projectRefresh) ?? 60);
    } else {
      await SharedPref().pref.setInt(SPConst.projectRefresh, 60);
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
    return TabViewTabHeadline(
      title: 'Projects',
      content: <Widget>[
        if (_dirPathError)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: informationWidget(
              'Your projects path isn\'t set. Try settings your projects path.',
              type: InformationType.error,
            ),
          ),
        RoundContainer(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Tooltip(
                  message: _dirPath ?? '',
                  waitDuration: const Duration(seconds: 1),
                  child: Text(
                    _dirPath ??
                        (_dirPathError
                            ? 'Please set your projects path...'
                            : 'Fetching your preferred project directory...'),
                    maxLines: 2,
                  ),
                ),
              ),
              HSeparators.normal(),
              if (_dirPath == null && !_dirPathError)
                const Spinner(size: 15, thickness: 2)
              else
                Tooltip(
                  waitDuration: const Duration(seconds: 1),
                  message: _dirPath == null ? 'Select Path' : 'Change Path',
                  child: IconButton(
                    color: Colors.transparent,
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.blueGrey,
                    ),
                    onPressed: () async {
                      String? projectsDirectory;
                      String? directoryPath =
                          await file_selector.getDirectoryPath(
                        initialDirectory: projectsDirectory,
                        confirmButtonText: 'Confirm',
                      );

                      if (directoryPath != null) {
                        setState(() {
                          _dirPathError = false;
                          _dirPath = directoryPath;
                        });
                        await SharedPref()
                            .pref
                            .setString(SPConst.projectsPath, directoryPath);

                        await logger.file(LogTypeTag.info,
                            'Projects path was set to: $directoryPath');
                      } else {
                        await logger.file(
                            LogTypeTag.warning, 'Projects path was not chosen');
                      }
                    },
                  ),
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
            PopupMenuButton<int>(
              tooltip: '',
              itemBuilder: (_) {
                return <PopupMenuEntry<int>>[
                  const PopupMenuItem<int>(value: 1, child: Text('1 minute')),
                  const PopupMenuItem<int>(value: 5, child: Text('5 minutes')),
                  const PopupMenuItem<int>(
                      value: 10, child: Text('10 minutes')),
                  const PopupMenuItem<int>(value: 60, child: Text('1 hour')),
                  const PopupMenuItem<int>(value: -1, child: Text('Never')),
                ];
              },
              onSelected: (int val) async {
                try {
                  await SharedPref().pref.setInt(SPConst.projectRefresh, val);
                  await ProjectsNotifier.updateProjectSettings(
                    (await getApplicationSupportDirectory()).path,
                    ProjectCacheSettings(
                      projectsPath: null,
                      refreshIntervals: val,
                      lastProjectReload: null,
                      lastWorkflowsReload: null,
                    ),
                  );
                  await logger.file(LogTypeTag.info,
                      'Projects refresh intervals was set to: $val');
                  setState(() => _refreshIntervals = val);
                } catch (e, s) {
                  await logger.file(LogTypeTag.error,
                      'Couldn\'t set projects refresh interval.',
                      error: e, stackTrace: s);

                  if (mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      snackBarTile(
                        context,
                        'Couldn\'t update your project refresh intervals.',
                        type: SnackBarType.error,
                      ),
                    );
                  }
                }
              },
              initialValue: SharedPref().pref.getInt(SPConst.projectRefresh),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: _refreshIntervals == -1
                    ? const Text('Never')
                    : (_refreshIntervals == 60
                        ? const Text('Every 1 hour')
                        : Text(
                            'Every $_refreshIntervals minute${_refreshIntervals > 1 ? 's' : ''}')),
              ),
            ),
          ],
        ),
        VSeparators.normal(),
      ],
    );
  }
}
