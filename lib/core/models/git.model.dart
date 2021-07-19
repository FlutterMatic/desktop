class GitAPI {
  Map<String, dynamic>? data;

  GitAPI(this.data);

  factory GitAPI.fromJson(Map<String, dynamic> content) {
    return GitAPI(content);
  }
}
