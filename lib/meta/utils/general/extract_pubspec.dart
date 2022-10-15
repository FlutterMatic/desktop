// 📦 Package imports:
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/services/logs.dart';

// TODO: Use a universal package for this, extracting pubspec.yaml files.
PubspecInfo extractPubspec({
  required List<String> lines,
  required String path,
}) {
  try {
    Pubspec info = Pubspec.parse(lines.join('\n'));

    // Project Configuration
    bool isNullSafety = false;

    // Checks if the project is null safety. If the dart version is greater than
    // or equal to 2.12.0 then null safe, otherwise not.
    for (String line in lines) {
      if (removeSpaces(line) == 'environment:') {
        String nextLine = lines[lines.indexOf(line) + 1];
        if (removeSpaces(nextLine).startsWith('sdk:')) {
          // Gets the constraints from the format such as the following
          // example:
          //   sdk: ">=2.14.0 <3.0.0"
          // We will convert the constraints to double so we can compare them.
          // We will also check if the version is greater than or equal to
          // 2.12.0. If it is then it's null safe.

          // We will also need to remove the second "." from the version. We only
          // want the first two numbers. We will also remove the operator such as
          // ">=", "<", etc.
          const List<String> operators = <String>[
            '<',
            '>',
            '<=',
            '>=',
            '==',
            '=',
          ];

          String min =
              nextLine.contains('"') ? nextLine.split('"')[1] : nextLine;

          for (String operator in operators) {
            min = min.replaceAll(operator, '');
          }

          min = min.contains('.')
              ? '${min.split('.')[0]}.${min.split('.')[1]}'
              : min;

          const List<String> itemsToRemove = <String>[
            ...operators,
            '"',
            ' ',
            "'",
            'sdk:',
          ];

          for (String item in itemsToRemove) {
            min = min.replaceAll(item, '');
          }

          min = removeSpaces(min);

          double versionDouble = double.parse(min);

          if (versionDouble >= 2.12) {
            isNullSafety = true;
            break;
          }
        }
      }
    }

    List<DependenciesInfo> dependenciesList = <DependenciesInfo>[];
    List<DependenciesInfo> devDependenciesList = <DependenciesInfo>[];

    info.dependencies.forEach((String key, Dependency value) {
      String version = value.toString().split(' ').last;

      dependenciesList
          .add(DependenciesInfo(name: key, version: version, isDev: false));
    });

    info.devDependencies.forEach((String key, Dependency value) {
      String version = value.toString().split(' ').last;

      devDependenciesList
          .add(DependenciesInfo(name: key, version: version, isDev: true));
    });

    // Remove the flutter dependency. We won't deal with it.
    dependenciesList.removeWhere((DependenciesInfo e) => e.name == 'flutter');

    return PubspecInfo(
      isValid: true,
      isFlutterProject: info.flutter != null,
      isNullSafety: isNullSafety,
      name: info.name,
      version: info.version,
      description: info.description,
      homepage: info.homepage,
      repository: info.repository,
      dependencies: dependenciesList,
      devDependencies: devDependenciesList,
      pathToPubspec: path,
    );
  } catch (e, s) {
    logger.file(LogTypeTag.error, 'Failed to extract pubspec file.',
        error: e, stackTrace: s);

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
