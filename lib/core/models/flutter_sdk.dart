class FlutterSDK {
  final Map<String, dynamic>? data;

  const FlutterSDK(this.data);

  factory FlutterSDK.fromJson(Map<String, dynamic> content) {
    return FlutterSDK(content);
  }
}
