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
    //  TODO: Implement.
    // SendPort port = data[0];
    // String supportDir = data[1];
    // bool force = data[2]; // Whether to force to refetch from scratch even if
    // // we have cache that is not expired.

    // if (await WorkflowSearchUtils.hasCache(supportDir)) {
    //   await logger.file(
    //       LogTypeTag.info, 'Fetching workflows from cache. Cache found.',
    //       logDir: Directory(supportDir));

    //   List<ProjectWorkflowsGrouped> workflowsCache =
    //       await WorkflowSearchUtils.getWorkflowsFromCache(supportDir);

    //   ProjectCacheSettings? cache =
    //       await ProjectsNotifier.getCacheSettings(supportDir);

    //   // Check to see if we need to refetch again because of time interval or cache
    //   // expired.
    //   if (cache != null) {
    //     // Cache expired. Will return the expired cache for performance, then will
    //     // refetch the cache in the background and update the listener with the
    //     // new cache if there is a difference to avoid unnecessary rebuilds.

    //     bool isExpiredCache = true;

    //     // Seconds Difference
    //     int difference = DateTime.now()
    //         .difference(cache.lastWorkflowsReload ?? DateTime.now())
    //         .inSeconds;

    //     // Check to see if the cache is expired. Interval in minutes. Must be
    //     // in seconds.
    //     if (((cache.refreshIntervals ?? 0) * 60) > difference) {
    //       isExpiredCache = false;
    //     }

    //     if (isExpiredCache || force) {
    //       if (force) {
    //         await logger.file(LogTypeTag.info,
    //             'Fetching workflows from cache. Cache expired. Force refetch.',
    //             logDir: Directory(supportDir));
    //       }

    //       await logger.file(LogTypeTag.info,
    //           'Fetching workflows from scratch. Cache expired.',
    //           logDir: Directory(supportDir));

    //       // Don't kill isolate. Will refetch with cache.
    //       port.send(<dynamic>[workflowsCache, false, true]);

    //       List<ProjectWorkflowsGrouped> workflowsRefetch =
    //           await WorkflowSearchUtils.getWorkflowsFromPath(
    //               cache: cache, supportDir: supportDir);

    //       // Update cache.
    //       await ProjectsNotifier.updateProjectCache(
    //         supportDir: supportDir,
    //         cache: ProjectCacheSettings(
    //           projectsPath: null,
    //           refreshIntervals: null,
    //           lastProjectReload: null,
    //           lastWorkflowsReload: DateTime.now(),
    //         ),
    //       );

    //       // Kill isolate. Cache is now updated.
    //       port.send(<dynamic>[workflowsRefetch, true, false]);
    //       return;
    //     } else {
    //       await logger.file(LogTypeTag.info,
    //           'Fetching workflows from cache. Cache still valid.',
    //           logDir: Directory(supportDir));
    //       // Kill isolate. Cache is still valid.
    //       port.send(<dynamic>[workflowsCache, true, false]);
    //       return;
    //     }
    //   } else {
    //     // Kill isolate.
    //     port.send(<dynamic>[workflowsCache, true, false]);
    //     return;
    //   }
    // } else {
    //   await logger.file(
    //       LogTypeTag.info, 'Fetching workflows initially. No cache found.',
    //       logDir: Directory(supportDir));
    //   List<ProjectWorkflowsGrouped> projectsPaths =
    //       await WorkflowSearchUtils.getWorkflowsFromPath(
    //     cache: await ProjectsNotifier.getCacheSettings(supportDir) ??
    //         const ProjectCacheSettings(
    //           lastProjectReload: null,
    //           projectsPath: null,
    //           refreshIntervals: null,
    //           lastWorkflowsReload: null,
    //         ),
    //     supportDir: supportDir,
    //   );

    //   // Kill isolate
    //   port.send(<dynamic>[projectsPaths, true, false]);
    //   return;
    // }
  }
}
