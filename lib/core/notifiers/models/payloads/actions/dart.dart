class NewDartProjectInfo {
  final String projectName;
  final String projectPath;
  final String template;

  const NewDartProjectInfo({
    required this.projectName,
    required this.projectPath,
    required this.template,
  });

  /// Ability to convert it to a JSON object.
  /// This is used for the [NewDartProjectInfo] class.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'projectName': projectName,
      'projectPath': projectPath,
      'template': template,
    };
  }
}
