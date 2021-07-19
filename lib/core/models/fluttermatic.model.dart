class FluttermaticAPI {
  Map<String, dynamic>? data;

  FluttermaticAPI(this.data);

  factory FluttermaticAPI.fromJson(Map<String, dynamic> content) {
    return FluttermaticAPI(content);
  }
}
