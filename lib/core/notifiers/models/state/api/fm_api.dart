import 'package:fluttermatic/core/models/fluttermatic.dart';

class FlutterMaticAPIState {
  final FlutterMaticAPI apiMap;

  const FlutterMaticAPIState({
    this.apiMap = const FlutterMaticAPI(null),
  });

  factory FlutterMaticAPIState.initial() => const FlutterMaticAPIState();

  FlutterMaticAPIState copyWith({
    FlutterMaticAPI? apiMap,
  }) {
    return FlutterMaticAPIState(
      apiMap: apiMap ?? this.apiMap,
    );
  }
}
