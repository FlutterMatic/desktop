class FlutterMaticAPI {
  Map<String, dynamic>? data;

  FlutterMaticAPI(this.data);

  factory FlutterMaticAPI.fromJson(Map<String, dynamic> content) {
    return FlutterMaticAPI(content);
  }
}
