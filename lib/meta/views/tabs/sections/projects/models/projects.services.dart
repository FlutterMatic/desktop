// 🎯 Dart imports:
import 'dart:isolate';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/shared_pref.dart';
import 'package:fluttermatic/core/libraries/models.dart';
import 'package:fluttermatic/core/libraries/services.dart';
import 'package:fluttermatic/core/libraries/utils.dart';
import 'package:fluttermatic/meta/utils/bin/utils/projects.search.dart';

class ProjectServicesModel {
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
  static Future<void> getProjectsIsolate(SendPort sendPort) async {
    // Init shared preference once again because we are on a different isolate.
    await SharedPref.init();

    if (await ProjectSearchUtils.hasCache()) {
      await logger.file(
          LogTypeTag.info, 'Fetching projects from cache. Cache found.');
      List<ProjectObject> _projectsCache =
          await ProjectSearchUtils.getProjectsFromCache();

      // Check to see if we need to refetch again because of time interval or cache
      // expired.
      if (SharedPref().pref.containsKey(SPConst.projectRefresh)) {
        // Cache expired. Will return the expired cache for performance, then will
        // refetch the cache in the background and update the listener with the
        // new cache if there is a difference to avoid unnecessary rebuilds.

        bool _isExpiredCache = true;

        if (SharedPref().pref.containsKey(SPConst.lastProjectsReload)) {
          String? _lastReload =
              SharedPref().pref.getString(SPConst.lastProjectsReload);

          int? _interval = SharedPref().pref.getInt(SPConst.projectRefresh);

          if (_lastReload != null && _interval != null) {
            // Seconds Difference
            int _difference = DateTime.now()
                .difference(DateTime.parse(_lastReload))
                .inSeconds;

            // Check to see if the cache is expired.
            // Interval in minutes. Must be in seconds.
            if (_difference < (_interval * 60)) {
              _isExpiredCache = false;
            }
          }
        }

        if (_isExpiredCache) {
          await logger.file(LogTypeTag.info,
              'Fetching projects from scratch. Cache expired.');

          // Don't kill isolate. Will refetch with cache.
          sendPort.send(<dynamic>[_projectsCache, false, true]);

          List<ProjectObject> _projectsRefetch =
              await ProjectSearchUtils.getProjectsFromPath();

          // Kill isolate. Cache is now updated.
          sendPort.send(<dynamic>[_projectsRefetch, true, false]);
        } else {
          await logger.file(LogTypeTag.info,
              'Fetching projects from cache. Cache still valid.');
          // Kill isolate. Cache is still valid.
          sendPort.send(<dynamic>[_projectsCache, true, false]);
        }
      } else {
        // Kill isolate.
        sendPort.send(<dynamic>[_projectsCache, true, false]);
      }

      return;
    } else {
      await logger.file(
          LogTypeTag.info, 'Fetching projects initially. No cache found.');
      List<ProjectObject> _projectsPaths =
          await ProjectSearchUtils.getProjectsFromPath();

      sendPort.send(<dynamic>[_projectsPaths, true, false]);
      return;
    }
  }
}
