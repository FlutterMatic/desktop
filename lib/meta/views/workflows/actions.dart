final List<WorkflowActionModel> workflowActionModels = <WorkflowActionModel>{
  const WorkflowActionModel(
    id: 'analyze_dart_project',
    name: 'Analyze',
    description:
        'Analyze the project for errors, warnings, and style recommendations.',
    type: WorkflowActionForType.both,
  ),
  const WorkflowActionModel(
    id: 'run_project_tests',
    name: 'Test',
    description: 'Test the project',
    type: WorkflowActionForType.both,
  ),
  const WorkflowActionModel(
    id: 'build_project_for_ios',
    name: 'Build iOS',
    description: 'Build the project for iOS devices.',
    type: WorkflowActionForType.flutter,
  ),
  const WorkflowActionModel(
    id: 'build_project_for_android',
    name: 'Build Android',
    description: 'Build the project for Android devices.',
    type: WorkflowActionForType.flutter,
  ),
  const WorkflowActionModel(
    id: 'build_project_for_web',
    name: 'Build Web',
    description: 'Build the project for Web.',
    type: WorkflowActionForType.flutter,
  ),
  const WorkflowActionModel(
    id: 'deploy_project_web',
    name: 'Deploy Web',
    description: 'Deploy the project web app with Firebase or npm command.',
    type: WorkflowActionForType.flutter,
  ),
}.toList();

enum WorkflowActionForType { flutter, dart, both }

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
