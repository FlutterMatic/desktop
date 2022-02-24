// 🎯 Dart imports:
import 'dart:io';

// 📦 Package imports:
import 'package:pub_api_client/pub_api_client.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/models/projects.model.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/bin/utils/workflow.search.dart';
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
      List<ProjectObject> _projectsResults = <ProjectObject>[];

      int _maxProjects = 10;

      // Remove from package results if not found in the query.
      _projectsResults.addAll(projects.where((_) {
        return _.name.toLowerCase().contains(query.toLowerCase()) ||
            _.description!.toLowerCase().contains(query.toLowerCase());
      }).toList());

      if (_projectsResults.isNotEmpty) {
        _projectsResults = _projectsResults.take(_maxProjects).toList();
      }

      // Share the projects result if any.
      if (_projectsResults.isNotEmpty) {
        yield <dynamic>['projects', _projectsResults, query];
      }

      /// SEARCHES FOR WORKFLOWS
      List<ProjectWorkflowsGrouped> _workflowResults =
          <ProjectWorkflowsGrouped>[];

      int _maxWorkflows = 2;

      // Remove from workflow results if not found in the query.
      _workflowResults.addAll(workflows.where((_) {
        bool _isGroupRelated =
            _.path.split('\\').last.toLowerCase().contains(query.toLowerCase());

        if (_isGroupRelated) {
          return true;
        }

        int _totalWorkflowMatches = 0;

        for (WorkflowTemplate template in _.workflows) {
          if (phraseMatch(template.name, query)) {
            _totalWorkflowMatches++;
          } else if (phraseMatch(template.description, query)) {
            _totalWorkflowMatches++;
          }
        }

        // Has to have at least 60% of the words in the query to be a match.
        return (_totalWorkflowMatches / _.workflows.length * 100 >= 60);
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

      if (_workflowResults.isNotEmpty) {
        _workflowResults = _workflowResults.take(_maxWorkflows).toList();
      }

      // Share the workflows if any.
      if (_workflowResults.isNotEmpty) {
        yield <dynamic>['workflows', _workflowResults, query];
      }

      /// SEARCHES FOR PUB PACKAGES
      List<PkgViewData> _pkgResults = <PkgViewData>[];

      try {
        yield <dynamic>[
          'loading',
          <String>['pub'],
          'start'
        ];

        SearchResults _pubResults =
            await _pubClient.search(query).timeout(const Duration(seconds: 3));

        int _maxPub = 3;
        int _pubLength = _pubResults.packages.length;

        for (int i = 0;
            i < (_pubLength > _maxPub ? _maxPub : _pubLength);
            i++) {
          String _name = _pubResults.packages[i].package;

          // Package Details
          PubPackage _info = await _pubClient.packageInfo(_name);
          PackageMetrics? _metrics = await _pubClient.packageMetrics(_name);
          PackagePublisher _publisher =
              await _pubClient.packagePublisher(_name);

          _pkgResults.add(
            PkgViewData(
              name: _name,
              info: _info,
              metrics: _metrics,
              publisher: _publisher,
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
      if (_pkgResults.isNotEmpty) {
        yield <dynamic>['packages', _pkgResults, query];
      }
      return;
    } catch (_, s) {
      print(_);
      print(s);
      await logger.file(
          LogTypeTag.error, 'Failed to perform app global search: $_',
          stackTraces: s, logDir: Directory(path));

      yield <dynamic>['error', <dynamic>[], query];
    }
  }

  static bool phraseMatch(String compare, String query) {
    compare = compare.toLowerCase();
    query = query.toLowerCase();

    List<String> _queryWords = _cleanSplit(query);
    List<String> _compareWords = _cleanSplit(compare);

    int _wordMatchCount = 0;

    for (String word in _queryWords) {
      for (String compare in _compareWords) {
        // Make sure that [compare] and [word] have at least 50% of the same
        // characters.
        List<String> _a = compare.split('');
        List<String> _b = word.split('');

        int _aLength = _a.length;

        int _aMatchCount = 0;

        for (String _aChar in _a) {
          if (_b.contains(_aChar)) {
            _aMatchCount++;
          }
        }

        if ((_aMatchCount / _aLength * 100) >= 50) {
          _wordMatchCount++;
        }
      }
    }

    // Has to have at least 60% of the words in the query to be a match.
    return (_wordMatchCount / _queryWords.length * 100) >= 60;
  }

  static List<String> _cleanSplit(String input) {
    List<String> _results = <String>[];

    Set<String> _splitCharacters = <String>{' ', '-', '_', '.', ','};

    // Replace all the split characters with a space.
    for (String _splitCharacter in _splitCharacters) {
      input = input.replaceAll(_splitCharacter, ' ');
    }

    // Split the input.
    _results = input.split(' ');

    // Remove repeated strings.
    _results = _results.toSet().toList();

    // Remove empty strings.
    _results = _results.where((_) => _.isNotEmpty).toList();

    return _results;
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
