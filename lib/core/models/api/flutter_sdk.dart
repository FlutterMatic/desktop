class FlutterSdkAPI {
  final Map<String, dynamic>? data;

  const FlutterSdkAPI(this.data);

  factory FlutterSdkAPI.fromJson(Map<String, dynamic> content) {
    return FlutterSdkAPI(content);
  }
}
