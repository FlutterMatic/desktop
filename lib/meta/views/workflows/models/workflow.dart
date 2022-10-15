// 🌎 Project imports:
import 'package:fluttermatic/app/enum.dart';
import 'package:fluttermatic/core/services/logs.dart';

class WorkflowTemplate {
  final String name;
  final String description;
  final String workflowPath;

  // Build Modes & Types
  final WebRenderers webRenderer;
  final AndroidBuildType androidBuildType;
  final PlatformBuildModes androidBuildMode;
  final PlatformBuildModes iOSBuildMode;
  final PlatformBuildModes webBuildMode;
  final PlatformBuildModes windowsBuildMode;
  final PlatformBuildModes macosBuildMode;
  final PlatformBuildModes linuxBuildMode;

  // Timeouts
  final int androidBuildTimeout;
  final int iOSBuildTimeout;
  final int webBuildTimeout;
  final int windowsBuildTimeout;
  final int macosBuildTimeout;
  final int linuxBuildTimeout;

  // Utils
  final String webUrl;
  final String firebaseProjectId;
  final String firebaseProjectName;
  final bool isFirebaseDeployVerified;
  final List<String> workflowActions;
  final List<String> customCommands;

  // Extra
  final bool isSaved;

  const WorkflowTemplate({
    required this.name,
    required this.description,
    required this.workflowPath,
    required this.webUrl,
    required this.firebaseProjectName,
    required this.firebaseProjectId,
    required this.androidBuildType,
    required this.androidBuildMode,
    required this.iOSBuildMode,
    required this.isFirebaseDeployVerified,
    required this.webRenderer,
    required this.webBuildMode,
    required this.workflowActions,
    required this.isSaved,
    required this.windowsBuildMode,
    required this.macosBuildMode,
    required this.linuxBuildMode,
    required this.androidBuildTimeout,
    required this.iOSBuildTimeout,
    required this.webBuildTimeout,
    required this.windowsBuildTimeout,
    required this.macosBuildTimeout,
    required this.linuxBuildTimeout,
    required this.customCommands,
  });

  // Ability to convert to a JSON
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'description': description,
      'workflowPath': workflowPath,
      'firebaseProjectId': firebaseProjectId,
      'firebaseProjectName': firebaseProjectName,
      'isFirebaseDeployVerified': isFirebaseDeployVerified,
      'webUrl': webUrl,
      'androidBuildTimeout': androidBuildTimeout,
      'iOSBuildTimeout': iOSBuildTimeout,
      'webBuildTimeout': webBuildTimeout,
      'windowsBuildTimeout': windowsBuildTimeout,
      'macosBuildTimeout': macosBuildTimeout,
      'linuxBuildTimeout': linuxBuildTimeout,
      'androidBuildType': androidBuildType.toString(),
      'androidBuildMode': androidBuildMode.toString(),
      'iOSBuildMode': iOSBuildMode.toString(),
      'webBuildMode': webBuildMode.toString(),
      'windowsBuildMode': windowsBuildMode.toString(),
      'macosBuildMode': macosBuildMode.toString(),
      'linuxBuildMode': linuxBuildMode.toString(),
      'webRenderer': webRenderer.toString(),
      'workflowActions': workflowActions,
      'customCommands': customCommands,
      'isSaved': isSaved,
    };
  }

  // Ability to convert from a JSON
  factory WorkflowTemplate.fromJson(Map<String, dynamic> json) {
    try {
      return WorkflowTemplate(
        // ...
        name: (json['name'] as String?) ?? 'No name',
        // ...
        description: (json['description'] as String?) ?? 'No description',
        // ...
        workflowPath: (json['workflowPath'] as String?) ?? '\\/',
        // ...
        webUrl: (json['webUrl'] as String?) ?? 'No web url',
        // ...
        firebaseProjectName: (json['firebaseProjectName'] as String?) ??
            'No firebase project name',
        // ...
        firebaseProjectId:
            (json['firebaseProjectId'] as String?) ?? 'No firebase project id',
        // ...
        isFirebaseDeployVerified:
            (json['isFirebaseDeployVerified'] as bool?) ?? false,
        // ...
        androidBuildType: AndroidBuildType.values.firstWhere(
            (AndroidBuildType e) => e.toString() == json['androidBuildType'],
            orElse: () => AndroidBuildType.appBundle),
        // ...
        androidBuildTimeout: (json['androidBuildTimeout'] as int?) ?? 0,
        // ...
        iOSBuildTimeout: (json['iOSBuildTimeout'] as int?) ?? 0,
        // ...
        linuxBuildTimeout: (json['linuxBuildTimeout'] as int?) ?? 0,
        // ...
        macosBuildTimeout: (json['macosBuildTimeout'] as int?) ?? 0,
        // ...
        webBuildTimeout: (json['webBuildTimeout'] as int?) ?? 0,
        // ...
        windowsBuildTimeout: (json['windowsBuildTimeout'] as int?) ?? 0,
        // ...
        androidBuildMode: PlatformBuildModes.values.firstWhere(
            (PlatformBuildModes e) => e.toString() == json['androidBuildMode'],
            orElse: () => PlatformBuildModes.release),
        // ...
        iOSBuildMode: PlatformBuildModes.values.firstWhere(
            (PlatformBuildModes e) => e.toString() == json['iOSBuildMode'],
            orElse: () => PlatformBuildModes.release),
        // ...
        webBuildMode: PlatformBuildModes.values.firstWhere(
            (PlatformBuildModes e) => e.toString() == json['webBuildMode'],
            orElse: () => PlatformBuildModes.release),
        // ...
        windowsBuildMode: PlatformBuildModes.values.firstWhere(
            (PlatformBuildModes e) => e.toString() == json['windowsBuildMode'],
            orElse: () => PlatformBuildModes.release),
        // ...
        macosBuildMode: PlatformBuildModes.values.firstWhere(
            (PlatformBuildModes e) => e.toString() == json['macosBuildMode'],
            orElse: () => PlatformBuildModes.release),
        // ...
        linuxBuildMode: PlatformBuildModes.values.firstWhere(
            (PlatformBuildModes e) => e.toString() == json['linuxBuildMode'],
            orElse: () => PlatformBuildModes.release),
        // ...
        webRenderer: WebRenderers.values.firstWhere(
            (WebRenderers e) => e.toString() == json['webRenderer'],
            orElse: () => WebRenderers.canvaskit),
        // ...
        workflowActions: ((json['workflowActions'] as List<dynamic>?)
                ?.map((dynamic e) => e.toString())
                .toList()) ??
            <String>[],
        // ...
        customCommands: ((json['customCommands'] as List<dynamic>?)
                ?.map((dynamic e) => e.toString())
                .toList()) ??
            <String>[],
        // ...
        isSaved: (json['isSaved'] as bool?) ?? false,
      );
    } catch (e, s) {
      logger.file(LogTypeTag.error,
          'WorkflowTemplate.fromJson() Failed to convert JSON to WorkflowTemplate. It might be missing some required fields or corrupted. JSON: $json',
          stackTrace: s);
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
