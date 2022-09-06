class GitAPI {
  final Map<String, dynamic>? data;

  const GitAPI(this.data);

  factory GitAPI.fromJson(Map<String, dynamic> content) {
    return GitAPI(content);
  }
}
