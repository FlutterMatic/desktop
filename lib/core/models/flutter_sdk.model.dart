class FlutterSDK {
  Map<String, dynamic>? data;

  FlutterSDK(this.data);

  factory FlutterSDK.fromJson(Map<String, dynamic> content) {
    return FlutterSDK(content);
  }
}
