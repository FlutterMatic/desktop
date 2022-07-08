import 'package:fluttermatic/core/models/vscode.dart';

class VSCodeAPIState {
  final VSCodeAPI vscMap;
  final String tagName;
  final String sha;

  const VSCodeAPIState({
    this.vscMap = const VSCodeAPI(data: null, gitData: null),
    this.tagName = '',
    this.sha = '',
  });

  factory VSCodeAPIState.initial() => const VSCodeAPIState();

  VSCodeAPIState copyWith({
    VSCodeAPI? vscMap,
    String? tagName,
    String? sha,
  }) {
    return VSCodeAPIState(
      vscMap: vscMap ?? this.vscMap,
      tagName: tagName ?? this.tagName,
      sha: sha ?? this.sha,
    );
  }
}
