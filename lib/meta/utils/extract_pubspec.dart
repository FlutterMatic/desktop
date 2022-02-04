// 📦 Package imports:
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/services/logs.dart';

PubspecInfo extractPubspec(
    {required List<String> lines, required String path}) {
  try {
    Pubspec _info = Pubspec.parse(lines.join('\n'));

    // Project Configuration
    bool _isNullSafety = false;

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

    List<DependenciesInfo> _dependenciesList = <DependenciesInfo>[];
    List<DependenciesInfo> _devDependenciesList = <DependenciesInfo>[];

    _info.dependencies.forEach((String key, Dependency value) {
      String _version = value.toString().split(' ').last;

      _dependenciesList
          .add(DependenciesInfo(name: key, version: _version, isDev: false));
    });

    _info.devDependencies.forEach((String key, Dependency value) {
      String _version = value.toString().split(' ').last;

      _devDependenciesList
          .add(DependenciesInfo(name: key, version: _version, isDev: true));
    });

    // Remove the flutter dependency. We won't deal with it.
    _dependenciesList.removeWhere((DependenciesInfo e) => e.name == 'flutter');

    return PubspecInfo(
      isValid: true,
      isFlutterProject: _info.flutter != null,
      isNullSafety: _isNullSafety,
      name: _info.name,
      version: _info.version,
      description: _info.description,
      homepage: _info.homepage,
      repository: _info.repository,
      dependencies: _dependenciesList,
      devDependencies: _devDependenciesList,
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
      homepage: null,
      repository: null,
      dependencies: <DependenciesInfo>[],
      devDependencies: <DependenciesInfo>[],
      pathToPubspec: null,
    );
  }
}

String removeSpaces(String line) {
  return line.replaceAll(' ', '');
}

class PubspecInfo {
  final bool isValid;
  final bool isFlutterProject;
  final bool isNullSafety;
  final String? name;
  final Version? version;
  final String? description;
  final String? homepage;
  final Uri? repository;
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
      'version': version.toString(),
      'description': description,
      'homepage': homepage,
      'repository': repository?.path,
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
      version: Version.parse(json['version']),
      description: json['description'] as String?,
      homepage: json['homepage'] as String?,
      pathToPubspec: json['pathToPubspec'] as String?,
      repository: Uri.tryParse(json['repository']),
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
