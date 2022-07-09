// 🎯 Dart imports:
import 'dart:io';

// 📦 Package imports:
import 'package:pub_api_client/pub_api_client.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/models/projects.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/search/workflow_search.dart';
import 'package:fluttermatic/meta/views/tabs/sections/pub/models/pkg_data.dart';
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';

class AppGlobalSearch {
  static final PubClient _pubClient = PubClient();

  static Stream<List<dynamic>> search({
    required String query,
    required String path,
    required List<ProjectObject> projects,
    required List<ProjectWorkflowsGrouped> workflows,
  }) async* {
    try {
      /// SEARCHES FOR PROJECTS
      List<ProjectObject> projectsResults = <ProjectObject>[];

      int maxProjects = 10;

      // Remove from package results if not found in the query.
      projectsResults.addAll(projects.where((_) {
        return _.name.toLowerCase().contains(query.toLowerCase()) ||
            _.description!.toLowerCase().contains(query.toLowerCase());
      }).toList());

      if (projectsResults.isNotEmpty) {
        projectsResults = projectsResults.take(maxProjects).toList();
      }

      // Share the projects result if any.
      if (projectsResults.isNotEmpty) {
        yield <dynamic>['projects', projectsResults, query];
      }

      // Searches for workflows
      List<ProjectWorkflowsGrouped> workflowResults =
          <ProjectWorkflowsGrouped>[];

      int maxWorkflows = 2;

      // Remove from workflow results if not found in the query.
      workflowResults.addAll(workflows.where((_) {
        bool isGroupRelated =
            _.path.split('\\').last.toLowerCase().contains(query.toLowerCase());

        if (isGroupRelated) {
          return true;
        }

        int totalWorkflowMatches = 0;

        for (WorkflowTemplate template in _.workflows) {
          if (phraseMatch(template.name, query)) {
            totalWorkflowMatches++;
          } else if (phraseMatch(template.description, query)) {
            totalWorkflowMatches++;
          }
        }

        // Has to have at least 60% of the words in the query to be a match.
        return (totalWorkflowMatches / _.workflows.length * 100 >= 60);
      }).toList());

      // List<String> _workflowPaths = <String>[];

      // List<ProjectWorkflowsGrouped> _copyWorkflows =
      //     <ProjectWorkflowsGrouped>[];

      // List<ProjectWorkflowsGrouped> _finalWorkflows =
      //     <ProjectWorkflowsGrouped>[];

      // _copyWorkflows.addAll(_workflowResults);

      // for (int j = 0; j < _copyWorkflows.length; j++) {
      //   ProjectWorkflowsGrouped _workflow = _copyWorkflows[j];
      //   if (!_workflowPaths.contains(_workflow.path)) {
      //     _finalWorkflows.add(_workflow);
      //     _workflowPaths.add(_workflow.path);
      //   }
      // }

      // if (_finalWorkflows.isNotEmpty) {
      //   _finalWorkflows = _finalWorkflows.take(_maxWorkflows).toList();
      // }

      // // Share the workflows if any.
      // if (_finalWorkflows.isNotEmpty) {
      //   yield <dynamic>['workflows', _finalWorkflows, query];
      // }

      if (workflowResults.isNotEmpty) {
        workflowResults = workflowResults.take(maxWorkflows).toList();
      }

      // Share the workflows if any.
      if (workflowResults.isNotEmpty) {
        yield <dynamic>['workflows', workflowResults, query];
      }

      /// SEARCHES FOR PUB PACKAGES
      List<PkgViewData> pkgResults = <PkgViewData>[];

      try {
        yield <dynamic>[
          'loading',
          <String>['pub'],
          'start'
        ];

        SearchResults pubResults =
            await _pubClient.search(query).timeout(const Duration(seconds: 3));

        int maxPub = 3;
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
      } catch (_) {
        yield <dynamic>[
          'loading',
          <String>['pub'],
          'error'
        ];
        return;
      }

      yield <dynamic>[
        'loading',
        <String>['pub'],
        'done'
      ];

      // Share the package results if available.
      if (pkgResults.isNotEmpty) {
        yield <dynamic>['packages', pkgResults, query];
      }
      return;
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to perform app global search: $_',
          stackTraces: s, logDir: Directory(path));

      yield <dynamic>['error', <dynamic>[], query];
    }
  }

  static bool phraseMatch(String compare, String query) {
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
