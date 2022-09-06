class VSCodeAPI {
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? gitData;

  const VSCodeAPI({this.data, this.gitData});

  factory VSCodeAPI.fromJson(
      {Map<String, dynamic>? content, Map<String, dynamic>? gitContent}) {
    return VSCodeAPI(data: content, gitData: gitContent);
  }
}
