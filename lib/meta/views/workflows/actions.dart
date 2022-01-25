final List<WorkflowActionModel> workflowActionModels = <WorkflowActionModel>{
  const WorkflowActionModel(
    id: WorkflowActionsIds.analyzeDartProject,
    name: 'Analyze',
    description:
        'Analyze the project for errors, warnings, and style recommendations.',
    type: WorkflowActionForType.both,
  ),
  const WorkflowActionModel(
    id: WorkflowActionsIds.runProjectTests,
    name: 'Test',
    description: 'Test the project',
    type: WorkflowActionForType.both,
  ),
  const WorkflowActionModel(
    id: WorkflowActionsIds.buildProjectForIOS,
    name: 'Build iOS',
    description: 'Build the project for iOS devices.',
    type: WorkflowActionForType.flutter,
  ),
  const WorkflowActionModel(
    id: WorkflowActionsIds.buildProjectForAndroid,
    name: 'Build Android',
    description: 'Build the project for Android devices.',
    type: WorkflowActionForType.flutter,
  ),
  const WorkflowActionModel(
    id: WorkflowActionsIds.buildProjectForWeb,
    name: 'Build Web',
    description: 'Build the project for Web.',
    type: WorkflowActionForType.flutter,
  ),
  const WorkflowActionModel(
    id: WorkflowActionsIds.buildProjectForWindows,
    name: 'Build Windows',
    description: 'Build the project for Windows.',
    type: WorkflowActionForType.flutter,
  ),
  const WorkflowActionModel(
    id: WorkflowActionsIds.buildProjectForMacOS,
    name: 'Build macOS',
    description: 'Build the project for macOS.',
    type: WorkflowActionForType.flutter,
  ),
  const WorkflowActionModel(
    id: WorkflowActionsIds.buildProjectForLinux,
    name: 'Build Linux',
    description: 'Build the project for Linux.',
    type: WorkflowActionForType.flutter,
  ),
  // const WorkflowActionModel(
  //   id: WorkflowActionsIds.deployProjectWeb,
  //   name: 'Deploy Web',
  //   description: 'Deploy the project web app with Firebase or npm command.',
  //   type: WorkflowActionForType.flutter,
  //   commands: <String>[],
  // ),
}.toList();

enum WorkflowActionForType { flutter, dart, both }

class WorkflowActionsIds {
  static const String analyzeDartProject = 'analyze_dart_project';
  static const String runProjectTests = 'run_project_tests';
  static const String buildProjectForIOS = 'build_project_for_ios';
  static const String buildProjectForAndroid = 'build_project_for_android';
  static const String buildProjectForWeb = 'build_project_for_web';
  static const String buildProjectForWindows = 'build_project_for_windows';
  static const String buildProjectForMacOS = 'build_project_for_macos';
  static const String buildProjectForLinux = 'build_project_for_linux';
  static const String deployProjectWeb = 'deploy_project_web';
}

class WorkflowActionModel {
  final String id;
  final String name;
  final String description;
  final WorkflowActionForType type;

  const WorkflowActionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
  });
}
