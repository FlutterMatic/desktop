class ProjectObject {
  final String name;
  final String? modDate;
  final String? description;
  final String path;

  const ProjectObject({
    required this.name,
    this.modDate,
    required this.path,
    required this.description,
  });
}
