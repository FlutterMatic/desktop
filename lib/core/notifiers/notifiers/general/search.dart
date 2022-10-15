// 📦 Package imports:
import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/search.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:pub_api_client/pub_api_client.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/models/projects.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/views/tabs/sections/pub/models/pkg_data.dart';
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';

class AppSearchNotifier extends StateNotifier<AppSearchState> {
  final Ref ref;

  AppSearchNotifier(this.ref) : super(const AppSearchState());

  static final PubClient _pubClient = PubClient();

  // Setters
  static final List _mergedResults = [
    ..._projects,
    ..._workflows,
    ..._packages,
  ];
  static final List<ProjectObject> _projects = [];
  static final List<ProjectWorkflowsGrouped> _workflows = [];
  static final List<PkgViewData> _packages = [];

  // Getters
  UnmodifiableListView get mergedResults =>
      UnmodifiableListView(_mergedResults);
  UnmodifiableListView<ProjectObject> get projects =>
      UnmodifiableListView(_projects);
  UnmodifiableListView<ProjectWorkflowsGrouped> get workflows =>
      UnmodifiableListView(_workflows);
  UnmodifiableListView<PkgViewData> get packages =>
      UnmodifiableListView(_packages);

  // {Query, Executable Search Function}.
  final List<MapEntry<String, Future<void>>> _searchQue = [];

  void resetSearch() {
    state = const AppSearchState();

    _projects.clear();
    _workflows.clear();
    _packages.clear();
  }

  Future<void> search(String query) async {
    // Cancel all previous ongoing searches.
    for (MapEntry<String, Future<void>> element in _searchQue.toList()) {
      StreamSubscription sub;
      sub = element.value.asStream().listen((event) {});

      await logger.file(
          LogTypeTag.info, 'Cancelling search query "${element.key}"');

      await sub.cancel();
    }

    _searchQue.clear();

    // Add the new search query.
    _searchQue.add(MapEntry(query, _newSearch(query)));

    await logger.file(LogTypeTag.info, 'Beginning search query "$query"');

    // Wait for the new search to finish.
    await _searchQue.last.value;

    // Remove the search queries from the queue.
    _searchQue.clear();
  }

  Future<void> _newSearch(String query) async {
    try {
      state = state.copyWith(
        loading: true,
        error: false,
        projectsError: false,
        workflowsError: false,
        pubError: false,
        currentActivity: '',
      );

      // Will initialize the projects and workflows if they are not already
      // initialized.
      if (!ref.watch(projectsActionStateNotifier).initialized) {
        await logger.file(LogTypeTag.info,
            'Began search without the projects being indexed. Indexing first.');

        state = state.copyWith(
          currentActivity: 'Indexing projects before search...',
        );

        await ref.read(projectsActionStateNotifier.notifier).getProjects(false);
      }

      if (!ref.watch(workflowsActionStateNotifier).initialized) {
        await logger.file(LogTypeTag.info,
            'Began search without the workflows being indexed. Indexing first.');

        state = state.copyWith(
          currentActivity: 'Indexing workflows before search...',
        );

        await ref
            .read(workflowsActionStateNotifier.notifier)
            .getWorkflows(false);
      }

      state = state.copyWith(
        currentActivity: '',
      );

      List<ProjectObject> projects =
          ref.watch(projectsActionStateNotifier.notifier).projects;
      List<ProjectWorkflowsGrouped> workflows =
          ref.watch(workflowsActionStateNotifier.notifier).workflows;

      // SEARCHES FOR PROJECTS
      List<ProjectObject> projectsResults = <ProjectObject>[];

      int maxProjects = 10;

      // Remove from package results if not found in the query.
      projectsResults.addAll(projects.where((_) {
        return _.name.toLowerCase().contains(query.toLowerCase()) ||
            (_.description ?? '').toLowerCase().contains(query.toLowerCase());
      }).toList());

      if (projectsResults.isNotEmpty) {
        projectsResults = projectsResults.take(maxProjects).toList();
      }

      _projects.clear();

      // Share the projects result if any.
      if (projectsResults.isNotEmpty) {
        _projects.addAll(projectsResults);
      }

      // SEARCHED FOR WORKFLOWS
      List<ProjectWorkflowsGrouped> workflowResults =
          <ProjectWorkflowsGrouped>[];

      int maxWorkflows = 10;

      // Remove from workflow results if not found in the query.
      workflowResults.addAll(workflows.where((e) {
        bool isGroupRelated = e.projectPath
            .split('\\')
            .last
            .toLowerCase()
            .contains(query.toLowerCase());

        if (isGroupRelated) {
          return true;
        }

        int totalWorkflowMatches = 0;

        for (WorkflowTemplate template in e.workflows) {
          if (_phraseMatch(template.name, query)) {
            totalWorkflowMatches++;
          } else if (_phraseMatch(template.description, query)) {
            totalWorkflowMatches++;
          }
        }

        // Has to have at least 60% of the words in the query to be a match.
        return (totalWorkflowMatches / e.workflows.length * 100 >= 60);
      }).toList());

      if (workflowResults.isNotEmpty) {
        workflowResults = workflowResults.take(maxWorkflows).toList();
      }

      _workflows.clear();

      // Share the workflows if any.
      if (workflowResults.isNotEmpty) {
        _workflows.addAll(workflowResults);
      }

      /// SEARCHES FOR PUB PACKAGES
      List<PkgViewData> pkgResults = <PkgViewData>[];

      try {
        SearchResults pubResults =
            await _pubClient.search(query).timeout(const Duration(seconds: 3));

        int maxPub = 6;
        int pubLength = pubResults.packages.length;

        for (int i = 0; i < (pubLength > maxPub ? maxPub : pubLength); i++) {
          String name = pubResults.packages[i].package;

          // Package Details
          PubPackage info = await _pubClient.packageInfo(name);
          PackageMetrics? metrics = await _pubClient.packageMetrics(name);
          PackagePublisher publisher = await _pubClient.packagePublisher(name);

          pkgResults.add(
            PkgViewData(
              name: name,
              info: info,
              metrics: metrics,
              publisher: publisher,
            ),
          );
        }

        _packages.clear();

        // Share the package results if available.
        if (pkgResults.isNotEmpty) {
          _packages.addAll(pkgResults);
        }
      } catch (e, s) {
        await logger.file(LogTypeTag.error,
            'Something went wrong when trying to perform pub search.',
            error: e, stackTrace: s);

        state = state.copyWith(
          pubError: true,
        );
      }

      state = state.copyWith(
        loading: false,
        error: false,
        currentActivity: '',
      );

      return;
    } catch (e, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to perform app global search.',
          error: e, stackTrace: s);

      if (mounted) {
        state = state.copyWith(
          error: true,
          loading: false,
          projectsError: false,
          workflowsError: false,
          pubError: false,
          currentActivity: '',
        );
      }

      return;
    }
  }

  static bool _phraseMatch(String compare, String query) {
    compare = compare.toLowerCase();
    query = query.toLowerCase();

    List<String> queryWords = _cleanSplit(query);
    List<String> compareWords = _cleanSplit(compare);

    int wordMatchCount = 0;

    for (String word in queryWords) {
      for (String compare in compareWords) {
        // Make sure that [compare] and [word] have at least 50% of the same
        // characters.
        List<String> a = compare.split('');
        List<String> b = word.split('');

        int aLength = a.length;

        int aMatchCount = 0;

        for (String aChar in a) {
          if (b.contains(aChar)) {
            aMatchCount++;
          }
        }

        if ((aMatchCount / aLength * 100) >= 50) {
          wordMatchCount++;
        }
      }
    }

    // Has to have at least 60% of the words in the query to be a match.
    return (wordMatchCount / queryWords.length * 100) >= 60;
  }

  static List<String> _cleanSplit(String input) {
    List<String> results = <String>[];

    Set<String> splitCharacters = <String>{' ', '-', '_', '.', ','};

    // Replace all the split characters with a space.
    for (String splitCharacter in splitCharacters) {
      input = input.replaceAll(splitCharacter, ' ');
    }

    // Split the input.
    results = input.split(' ');

    // Remove repeated strings.
    results = results.toSet().toList();

    // Remove empty strings.
    results = results.where((_) => _.isNotEmpty).toList();

    return results;
  }
}

class AppSearchResult {
  final String type;
  final dynamic content;

  const AppSearchResult({
    required this.type,
    required this.content,
  });
}
