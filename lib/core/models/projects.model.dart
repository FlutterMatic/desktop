class ProjectObject {
  final String name;
  final DateTime modDate;
  final String? description;
  final String path;

  const ProjectObject({
    required this.name,
    required this.modDate,
    required this.path,
    required this.description,
  });
}
