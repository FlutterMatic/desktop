import 'package:fluttermatic/core/services/logs.dart';

PubspecInfo extractPubspec({
  required List<String> lines,
  required String path,
}) {
  try {
    for (String e in lines) {
      print('\'$e\',');
    }
    // Dependencies. This includes both the "dependencies" and "dev_dependencies".
    DependencyExtraction? _dependencies;

    // Project Configuration
    bool _isFlutterProject = false;
    bool _isNullSafety = false;

    // Project Information
    String? _name;
    String? _version;
    String? _description;
    String? _author;
    String? _homepage;
    String? _repository;

    // Gets the dependencies from the pubspec file.
    _dependencies = _extractDependencies(lines);

    // Check if it is a flutter project. We can know if the following exists:
    // flutter:
    //  sdk: flutter
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('flutter:')) {
        print(removeSpaces(lines[i]));
        print('flutter:');
        print(removeSpaces(lines[i]) == removeSpaces('flutter:'));
        print(lines[i]);
        break;
      }
      // if (lines[i].contains('flutter:')) {
      //   print(removeSpaces(lines[i]));
      //   print('flutter:');
      //   print(removeSpaces(lines[i]) == removeSpaces('flutter:'));
      //   print(lines[i + 1]);
      //   break;
      // }
      if (removeSpaces(lines[i]) == 'flutter:') {
        String _nextLine = lines[i + 1];
        if (removeSpaces(_nextLine) == 'sdk:flutter') {
          _isFlutterProject = true;
          break;
        }
      }
    }

    const List<String> _fields = <String>[
      'name:',
      'version:',
      'description:',
      'author:',
      'homepage:',
      'repository:',
    ];

    // Gets the fields from the pubspec file.
    for (String line in lines) {
      for (String field in _fields) {
        if (removeSpaces(line).startsWith(field)) {
          if (field == 'name:') {
            _name = line.substring(field.length).trim();
          } else if (field == 'version:') {
            _version = removeSpaces(line.split(':')[1]);
            break;
          } else if (field == 'description:') {
            _description = line.split(':').sublist(1).join(':').trim();
            break;
          } else if (field == 'author:') {
            _author = line.split(':').sublist(1).join(':').trim();
            break;
          } else if (field == 'homepage:') {
            _homepage = removeSpaces(line.split(':')[1]);
            break;
          } else if (field == 'repository:') {
            _repository = removeSpaces(line.split(':')[1]);
            break;
          }
        }
      }
    }

    // Checks if the project is null safety. If the dart version is greater than
    // or equal to 2.12.0 then null safe, otherwise not.
    for (String line in lines) {
      if (removeSpaces(line) == 'environment:') {
        String _nextLine = lines[lines.indexOf(line) + 1];
        if (removeSpaces(_nextLine).startsWith('sdk:')) {
          // Gets the constraints from the format such as the following
          // example:
          //   sdk: ">=2.14.0 <3.0.0"
          // We will convert the constraints to double so we can compare them.
          // We will also check if the version is greater than or equal to
          // 2.12.0. If it is then it's null safe.

          // We will also need to remove the second "." from the version. We only
          // want the first two numbers. We will also remove the operator such as
          // ">=", "<", etc.
          const List<String> _operators = <String>[
            '<',
            '>',
            '<=',
            '>=',
            '==',
            '=',
          ];

          String _min =
              _nextLine.contains('"') ? _nextLine.split('"')[1] : _nextLine;

          for (String operator in _operators) {
            _min = _min.replaceAll(operator, '');
          }

          _min = _min.contains('.')
              ? _min.split('.')[0] + '.' + _min.split('.')[1]
              : _min;

          const List<String> _itemsToRemove = <String>[
            ..._operators,
            '"',
            ' ',
            "'",
            'sdk:',
          ];

          for (String item in _itemsToRemove) {
            _min = _min.replaceAll(item, '');
          }

          _min = removeSpaces(_min);

          double _versionDouble = double.parse(_min);

          if (_versionDouble >= 2.12) {
            _isNullSafety = true;
            break;
          }
        }
      }
    }

    return PubspecInfo(
      isValid: true,
      isFlutterProject: _isFlutterProject,
      isNullSafety: _isNullSafety,
      name: _name,
      version: _version,
      description: _description,
      author: _author,
      homepage: _homepage,
      repository: _repository,
      dependencies: _dependencies.dependencies
          .where((DependenciesInfo element) => !element.isDev)
          .toList(),
      devDependencies: _dependencies.dependencies
          .where((DependenciesInfo element) => element.isDev)
          .toList(),
      pathToPubspec: path,
    );
  } catch (_, s) {
    logger.file(LogTypeTag.error, 'Failed to extract pubspec file: $_',
        stackTraces: s);
    return const PubspecInfo(
      isValid: false,
      isFlutterProject: false,
      isNullSafety: false,
      name: null,
      version: null,
      description: null,
      author: null,
      homepage: null,
      repository: null,
      dependencies: <DependenciesInfo>[],
      devDependencies: <DependenciesInfo>[],
      pathToPubspec: null,
    );
  }
}

/// Will extract the list of dependencies from a pubspec.yaml file. Returns a list of key value
/// pairs. The key is the dependency name and the value is the version.
///
/// Provide the pubspec.yaml file as a [List<String>]. You can read the pubspec.yaml from memory
/// by lines. This helps it become easier to perform sorting of the dependencies.
DependencyExtraction _extractDependencies(List<String> pubspec) {
  List<DependenciesInfo> _dependencies = <DependenciesInfo>[];
  List<int> _dependencyLineIndexes = <int>[];

  int _startIndex = 0;
  int _finalIndex = 0;

  _startIndex = pubspec.indexOf('dependencies:');

  int _flutterDecIndex = pubspec.indexOf('flutter:');
  _finalIndex = _flutterDecIndex == -1 ? pubspec.length : _flutterDecIndex;

  int _devStartDecIndex = pubspec.indexOf('dev_dependencies:');

  for (int i = 0; i < pubspec.length; i++) {
    String _line = pubspec[i];

    int _currentIndex = pubspec.indexOf(_line);
    if (_currentIndex < _startIndex || _currentIndex > _finalIndex) {
      continue;
    }

    if (_line.contains(':')) {
      List<String> _pairs = _line.split(':');

      if (_pairs.length != 2) {
        continue;
      }

      // The [_pair[0]] is the possible dependency name while [_pair[1]] is the possible dependency
      // version. Follow this annotation structure.
      String _name() {
        int _startIndex = _pairs[0].indexOf((_pairs[0].split('').firstWhere(
            (String element) => RegExp('[a-z]').hasMatch(element))));

        return _pairs[0][_startIndex] + _pairs[0].substring(_startIndex + 1);
      }

      // The conditions that must satisfy in order for it to be considered as a dependency.
      List<bool> _pairConditions = <bool>[
        !removeSpaces(_pairs[0]).startsWith('#'),
        RegExp('[a-z]').hasMatch(removeSpaces(_pairs[0])),
        _pairs[1].contains(RegExp('[0-9]')) || removeSpaces(_pairs[1]) == 'any',
      ];

      bool _success = true;

      for (bool element in _pairConditions) {
        if (!element) {
          _success = false;
        }
      }

      if (_success) {
        _dependencies.add(DependenciesInfo(
          name: _name(),
          version: _pairs[1].startsWith('^') ? _pairs[1] : '^' + _pairs[1],
          isDev: _devStartDecIndex < i,
        ));
        _dependencyLineIndexes.add(i);
      }
    }
  }

  return DependencyExtraction(
    dependencies: _dependencies,
    dependenciesIndexes: _dependencyLineIndexes,
  );
}

String removeSpaces(String line) {
  return line.replaceAll(' ', '');
}

class PubspecInfo {
  final bool isValid;
  final bool isFlutterProject;
  final bool isNullSafety;
  final String? name;
  final String? version;
  final String? description;
  final String? author;
  final String? homepage;
  final String? repository;
  final String? pathToPubspec;

  final List<DependenciesInfo> dependencies;
  final List<DependenciesInfo> devDependencies;

  const PubspecInfo({
    // Validation Information
    required this.isValid,
    required this.isFlutterProject,
    required this.isNullSafety,

    // Pubspec Information
    required this.name,
    required this.version,
    required this.description,
    required this.author,
    required this.homepage,
    required this.repository,
    required this.dependencies,
    required this.devDependencies,
    required this.pathToPubspec,
  });

  /// Ability to convert to JSON for serialization.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'isValid': isValid,
      'isFlutterProject': isFlutterProject,
      'isNullSafety': isNullSafety,
      'name': name,
      'version': version,
      'description': description,
      'author': author,
      'homepage': homepage,
      'repository': repository,
      'pathToPubspec': pathToPubspec,
      'dependencies': dependencies
          .map((DependenciesInfo element) => element.toJson())
          .toList(),
      'devDependencies': devDependencies
          .map((DependenciesInfo element) => element.toJson())
          .toList(),
    };
  }

  /// Ability to parse from JSON.
  factory PubspecInfo.fromJson(Map<String, dynamic> json) {
    return PubspecInfo(
      isValid: json['isValid'] as bool,
      isFlutterProject: json['isFlutterProject'] as bool,
      isNullSafety: json['isNullSafety'] as bool,
      name: json['name'] as String?,
      version: json['version'] as String?,
      description: json['description'] as String?,
      author: json['author'] as String?,
      homepage: json['homepage'] as String?,
      pathToPubspec: json['pathToPubspec'] as String?,
      repository: json['repository'] as String?,
      dependencies: (json['dependencies'] as List<dynamic>)
          // ignore: unnecessary_lambdas
          .map((dynamic element) => DependenciesInfo.fromJson(element))
          .toList(),
      devDependencies: (json['devDependencies'] as List<dynamic>)
          // ignore: unnecessary_lambdas
          .map((dynamic element) => DependenciesInfo.fromJson(element))
          .toList(),
    );
  }
}

class DependenciesInfo {
  final String name;
  final String version;

  /// Whether or not it is a development package which means only available in
  /// the development environment.
  final bool isDev;

  const DependenciesInfo({
    required this.name,
    required this.version,
    required this.isDev,
  });

  /// Ability to convert to JSON
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'version': version,
      'isDev': isDev,
    };
  }

  /// Ability to parse from JSON
  factory DependenciesInfo.fromJson(Map<String, dynamic> json) {
    return DependenciesInfo(
      name: json['name'] as String,
      version: json['version'] as String,
      isDev: json['isDev'] as bool,
    );
  }
}

class DependencyExtraction {
  /// The list if file indexes starting from 0 of where there is a dependency
  /// declaration expected.
  final List<int> dependenciesIndexes;

  /// The list of dependencies that are fetched from the indexes.
  final List<DependenciesInfo> dependencies;

  const DependencyExtraction({
    required this.dependenciesIndexes,
    required this.dependencies,
  });
}
