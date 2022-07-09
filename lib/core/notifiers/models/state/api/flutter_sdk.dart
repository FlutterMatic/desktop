// 🌎 Project imports:
import 'package:fluttermatic/core/models/flutter_sdk.dart';

class FlutterSDKState {
  final FlutterSDK sdkMap;
  final String sdk;

  const FlutterSDKState({
    this.sdkMap = const FlutterSDK(<String, dynamic>{}),
    this.sdk = '',
  });

  factory FlutterSDKState.initial() => const FlutterSDKState();

  FlutterSDKState copyWith({
    FlutterSDK? sdkMap,
    String? sdk,
  }) {
    return FlutterSDKState(
      sdkMap: sdkMap ?? this.sdkMap,
      sdk: sdk ?? this.sdk,
    );
  }
}
