class FlutterMaticAPI {
  final Map<String, dynamic>? data;

  const FlutterMaticAPI(this.data);

  factory FlutterMaticAPI.fromJson(Map<String, dynamic> content) {
    return FlutterMaticAPI(content);
  }
}
