class VSCodeAPI {
  Map<String, dynamic>? data;
  Map<String, dynamic>? gitData;

  VSCodeAPI({this.data, this.gitData});

  factory VSCodeAPI.fromJson({Map<String, dynamic>? content,
      Map<String, dynamic>? gitContent}) {
    return VSCodeAPI(data: content, gitData: gitContent);
  }
}
