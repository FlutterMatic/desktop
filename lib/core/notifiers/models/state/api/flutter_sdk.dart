// 🌎 Project imports:
import 'package:fluttermatic/core/models/api/flutter_sdk.dart';

class FlutterSDKState {
  final FlutterSdkAPI sdkMap;
  final String sdk;

  const FlutterSDKState({
    this.sdkMap = const FlutterSdkAPI(<String, dynamic>{}),
    this.sdk = '',
  });

  factory FlutterSDKState.initial() => const FlutterSDKState();

  FlutterSDKState copyWith({
    FlutterSdkAPI? sdkMap,
    String? sdk,
  }) {
    return FlutterSDKState(
      sdkMap: sdkMap ?? this.sdkMap,
      sdk: sdk ?? this.sdk,
    );
  }
}
