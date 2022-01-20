// 🌎 Project imports:
import 'package:fluttermatic/core/libraries/constants.dart';
import 'package:fluttermatic/core/libraries/services.dart';

class WorkflowTemplate {
  final String name;
  final String description;
  final String webUrl;
  final String firebaseProjectName;
  final String firebaseProjectId;
  final PlatformBuildModes iOSBuildMode;
  final PlatformBuildModes androidBuildMode;
  final bool isFirebaseDeployVerified;
  final WebRenderers defaultWebRenderer;
  final PlatformBuildModes defaultWebBuildMode;
  final List<String> workflowActions;
  final bool isSaved;

  const WorkflowTemplate({
    required this.name,
    required this.description,
    required this.webUrl,
    required this.firebaseProjectName,
    required this.firebaseProjectId,
    required this.iOSBuildMode,
    required this.androidBuildMode,
    required this.isFirebaseDeployVerified,
    required this.defaultWebRenderer,
    required this.defaultWebBuildMode,
    required this.workflowActions,
    required this.isSaved,
  });

  // Ability to convert to a JSON
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'description': description,
      'webUrl': webUrl,
      'firebaseProjectName': firebaseProjectName,
      'firebaseProjectId': firebaseProjectId,
      'iOSBuildMode': iOSBuildMode.toString(),
      'androidBuildMode': androidBuildMode.toString(),
      'isFirebaseDeployVerified': isFirebaseDeployVerified,
      'defaultWebRenderer': defaultWebRenderer.toString(),
      'defaultWebBuildMode': defaultWebBuildMode.toString(),
      'workflowActions': workflowActions,
      'isSaved': isSaved,
    };
  }

  // Ability to convert from a JSON
  factory WorkflowTemplate.fromJson(Map<String, dynamic> json) {
    try {
      return WorkflowTemplate(
        name: json['name'] as String,
        description: json['description'] as String,
        webUrl: json['webUrl'] as String,
        firebaseProjectName: json['firebaseProjectName'] as String,
        firebaseProjectId: json['firebaseProjectId'] as String,
        iOSBuildMode: PlatformBuildModes.values.firstWhere(
            (PlatformBuildModes e) => e.toString() == json['iOSBuildMode']),
        androidBuildMode: PlatformBuildModes.values.firstWhere(
            (PlatformBuildModes e) => e.toString() == json['androidBuildMode']),
        isFirebaseDeployVerified: json['isFirebaseDeployVerified'] as bool,
        defaultWebRenderer: WebRenderers.values.firstWhere(
            (WebRenderers e) => e.toString() == json['defaultWebRenderer']),
        defaultWebBuildMode: PlatformBuildModes.values.firstWhere(
            (PlatformBuildModes e) =>
                e.toString() == json['defaultWebBuildMode']),
        workflowActions: (json['workflowActions'] as List<dynamic>)
            .map((dynamic e) => e.toString())
            .toList(),
        isSaved: json['isSaved'] as bool,
      );
    } catch (_, s) {
      logger.file(LogTypeTag.error,
          'WorkflowTemplate.fromJson() Failed to convert JSON to WorkflowTemplate. It might be missing some required fields or corrupted. JSON: $json',
          stackTraces: s);
      throw Exception(
          'Failed to parse WorkflowTemplate from JSON. Template: $json');
    }
  }

  // Ability to verify a hash. This is done by combining all values together,
  // then getting its hash, and comparing with the provided hash.
  bool verifyHash(int hash) {
    return hash == generateHash();
  }

  // Ability to generate the hash code for the data provided.
  int generateHash() {
    return Object.hash(
      name,
      description,
      webUrl,
      firebaseProjectName,
      firebaseProjectId,
      iOSBuildMode,
      androidBuildMode,
      isFirebaseDeployVerified,
      defaultWebRenderer,
      defaultWebBuildMode,
      workflowActions,
    );
  }
}
