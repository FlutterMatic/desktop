// 🌎 Project imports:
import 'package:fluttermatic/core/libraries/constants.dart';
import 'package:fluttermatic/core/libraries/services.dart';

class WorkflowTemplate {
  final String name;
  final String description;
  final String firebaseProjectId;
  final String firebaseProjectName;
  final String webUrl;
  final bool isFirebaseDeployVerified;
  final WebRenderers webRenderer;
  final PlatformBuildModes iOSBuildMode;
  final PlatformBuildModes androidBuildMode;
  final PlatformBuildModes webBuildMode;
  final PlatformBuildModes windowsBuildMode;
  final PlatformBuildModes macosBuildMode;
  final PlatformBuildModes linuxBuildMode;
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
    required this.webRenderer,
    required this.webBuildMode,
    required this.workflowActions,
    required this.isSaved,
    required this.windowsBuildMode,
    required this.macosBuildMode,
    required this.linuxBuildMode,
  });

  // Ability to convert to a JSON
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'description': description,
      'firebaseProjectId': firebaseProjectId,
      'firebaseProjectName': firebaseProjectName,
      'isFirebaseDeployVerified': isFirebaseDeployVerified,
      'webUrl': webUrl,
      'iOSBuildMode': iOSBuildMode.toString(),
      'androidBuildMode': androidBuildMode.toString(),
      'webBuildMode': webBuildMode.toString(),
      'windowsBuildMode': windowsBuildMode.toString(),
      'macosBuildMode': macosBuildMode.toString(),
      'linuxBuildMode': linuxBuildMode.toString(),
      'webRenderer': webRenderer.toString(),
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
        isFirebaseDeployVerified: json['isFirebaseDeployVerified'] as bool,
        iOSBuildMode: PlatformBuildModes.values.firstWhere(
            (PlatformBuildModes e) => e.toString() == json['iOSBuildMode']),
        androidBuildMode: PlatformBuildModes.values.firstWhere(
            (PlatformBuildModes e) => e.toString() == json['androidBuildMode']),
        webBuildMode: PlatformBuildModes.values.firstWhere(
            (PlatformBuildModes e) => e.toString() == json['webBuildMode']),
        windowsBuildMode: PlatformBuildModes.values.firstWhere(
            (PlatformBuildModes e) => e.toString() == json['windowsBuildMode']),
        macosBuildMode: PlatformBuildModes.values.firstWhere(
            (PlatformBuildModes e) => e.toString() == json['macosBuildMode']),
        linuxBuildMode: PlatformBuildModes.values.firstWhere(
            (PlatformBuildModes e) => e.toString() == json['linuxBuildMode']),
        webRenderer: WebRenderers.values.firstWhere(
            (WebRenderers e) => e.toString() == json['webRenderer']),
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
      webRenderer,
      webBuildMode,
      workflowActions,
      isSaved,
      windowsBuildMode,
      macosBuildMode,
      linuxBuildMode,
    );
  }
}
