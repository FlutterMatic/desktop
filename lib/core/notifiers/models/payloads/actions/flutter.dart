class NewFlutterProjectInfo {
  final String projectName;
  final String projectPath;
  final String description;
  final String orgName;
  final Map<String, dynamic> firebaseJson;
  final bool iOS;
  final bool android;
  final bool web;
  final bool windows;
  final bool macos;
  final bool linux;

  const NewFlutterProjectInfo({
    required this.projectName,
    required this.projectPath,
    required this.description,
    required this.orgName,
    required this.firebaseJson,
    required this.iOS,
    required this.android,
    required this.web,
    required this.windows,
    required this.macos,
    required this.linux,
  });

  /// Ability to convert it to a JSON object.
  /// This is used for the [NewFlutterProjectInfo] class.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'projectName': projectName,
      'projectPath': projectPath,
      'description': description,
      'orgName': orgName,
      'firebaseJson': firebaseJson,
      'iOS': iOS,
      'android': android,
      'web': web,
      'windows': windows,
      'macos': macos,
      'linux': linux,
    };
  }
}
