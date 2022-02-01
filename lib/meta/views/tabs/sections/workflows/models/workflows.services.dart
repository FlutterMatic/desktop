// 🎯 Dart imports:
import 'dart:io';
import 'dart:isolate';

// 🌎 Project imports:
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/bin/utils/workflow.search.dart';
import 'package:fluttermatic/meta/views/tabs/sections/projects/models/projects.services.dart';

class WorkflowServicesModel {
  /// If we have cache, we will use it to improve performance. After we send to
  /// the port listener, we will then fetch again to update the cache in the
  /// background.
  ///
  /// The first is the list of projects, the second is a boolean. True means
  /// that we want to kill the isolate and false means there is another response
  /// coming in soon so don't kill the isolate. The third item in the list is a
  /// boolean meaning is it refetching from cache or not.
  ///
  /// **RESPONSE FORMAT**:
  /// [<List> projects, <boolean> killIsolate, <boolean> isExpectedAnotherResponse]
  static Future<void> getWorkflowsIsolate(List<dynamic> data) async {
    SendPort _port = data[0];
    String _supportDir = data[1];
    bool _force = data[2]; // Whether to force to refetch from scratch even if
    // we have cache that is not expired.

    if (await WorkflowSearchUtils.hasCache(_supportDir)) {
      await logger.file(
          LogTypeTag.info, 'Fetching workflows from cache. Cache found.',
          logDir: Directory(_supportDir));

      List<ProjectWorkflowsGrouped> _workflowsCache =
          await WorkflowSearchUtils.getWorkflowsFromCache(_supportDir);

      ProjectCacheResult? _cache =
          await ProjectServicesModel.getProjectCache(_supportDir);

      // Check to see if we need to refetch again because of time interval or cache
      // expired.
      if (_cache != null) {
        // Cache expired. Will return the expired cache for performance, then will
        // refetch the cache in the background and update the listener with the
        // new cache if there is a difference to avoid unnecessary rebuilds.

        bool _isExpiredCache = true;

        // Seconds Difference
        int _difference = DateTime.now()
            .difference(_cache.lastWorkflowsReload ?? DateTime.now())
            .inSeconds;

        // Check to see if the cache is expired. Interval in minutes. Must be
        // in seconds.
        if (((_cache.refreshIntervals ?? 0) * 60) > _difference) {
          _isExpiredCache = false;
        }

        if (_isExpiredCache || _force) {
          if (_force) {
            await logger.file(LogTypeTag.info,
                'Fetching workflows from cache. Cache expired. Force refetch.',
                logDir: Directory(_supportDir));
          }

          await logger.file(LogTypeTag.info,
              'Fetching workflows from scratch. Cache expired.',
              logDir: Directory(_supportDir));

          // Don't kill isolate. Will refetch with cache.
          _port.send(<dynamic>[_workflowsCache, false, true]);

          List<ProjectWorkflowsGrouped> _workflowsRefetch =
              await WorkflowSearchUtils.getWorkflowsFromPath(
                  cache: _cache, supportDir: _supportDir);

          // Update cache.
          await ProjectServicesModel.updateProjectCache(
            supportDir: _supportDir,
            cache: ProjectCacheResult(
              projectsPath: null,
              refreshIntervals: null,
              lastProjectReload: null,
              lastWorkflowsReload: DateTime.now(),
            ),
          );

          // Kill isolate. Cache is now updated.
          _port.send(<dynamic>[_workflowsRefetch, true, false]);
          return;
        } else {
          await logger.file(LogTypeTag.info,
              'Fetching workflows from cache. Cache still valid.',
              logDir: Directory(_supportDir));
          // Kill isolate. Cache is still valid.
          _port.send(<dynamic>[_workflowsCache, true, false]);
          return;
        }
      } else {
        // Kill isolate.
        _port.send(<dynamic>[_workflowsCache, true, false]);
        return;
      }
    } else {
      await logger.file(
          LogTypeTag.info, 'Fetching workflows initially. No cache found.',
          logDir: Directory(_supportDir));
      List<ProjectWorkflowsGrouped> _projectsPaths =
          await WorkflowSearchUtils.getWorkflowsFromPath(
        cache: await ProjectServicesModel.getProjectCache(_supportDir) ??
            const ProjectCacheResult(
              lastProjectReload: null,
              projectsPath: null,
              refreshIntervals: null,
              lastWorkflowsReload: null,
            ),
        supportDir: _supportDir,
      );

      // Kill isolate
      _port.send(<dynamic>[_projectsPaths, true, false]);
      return;
    }
  }
}
