class ProjectObject {
  final String name;
  final DateTime modDate;
  final String? description;
  final String path;
  final bool pinned;

  const ProjectObject({
    required this.name,
    required this.modDate,
    required this.path,
    required this.description,
    required this.pinned,
  });

  // Ability to convert to JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'modDate': modDate.toIso8601String(),
      'description': description,
      'path': path,
      'pinned': pinned,
    };
  }

  // Ability to convert from JSON.
  factory ProjectObject.fromJson(Map<String, dynamic> json) {
    return ProjectObject(
      name: json['name'] as String,
      modDate: DateTime.parse(json['modDate'] as String),
      description: json['description'] as String?,
      path: json['path'] as String,
      pinned: json['pinned'] as bool,
    );
  }

  ProjectObject copyWith({
    String? name,
    DateTime? modDate,
    String? description,
    String? path,
    bool? pinned,
  }) {
    return ProjectObject(
      name: name ?? this.name,
      modDate: modDate ?? this.modDate,
      description: description ?? this.description,
      path: path ?? this.path,
      pinned: pinned ?? this.pinned,
    );
  }
}
