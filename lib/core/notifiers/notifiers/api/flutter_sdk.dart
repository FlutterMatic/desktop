// 🎯 Dart imports:
import 'dart:convert';

// 🐦 Flutter imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/core/models/flutter_sdk.dart';
import 'package:fluttermatic/core/notifiers/models/state/api/flutter_sdk.dart';
import 'package:fluttermatic/core/notifiers/models/state/api/fm_api.dart';
import 'package:fluttermatic/core/notifiers/out.dart';

// 📦 Package imports:
import 'package:http/http.dart' as http;

class FlutterSDKNotifier extends StateNotifier<FlutterSDKState> {
  final Reader read;

  FlutterSDKNotifier(this.read) : super(FlutterSDKState.initial());

  /// Will fetch the Flutter SDK latest data.
  ///
  /// This will get the latest release information, including the version,
  /// branch, and other useful information.
  Future<void> fetchSDKData() async {
    FlutterMaticAPIState api = read(fmAPIStateNotifier);

    http.Response response = await http.get(Uri.parse(
        api.apiMap.data!['flutter']['base_url'] + api.apiMap.data!['flutter'][platform]));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      state = state.copyWith(
        sdkMap: FlutterSDK.fromJson(jsonDecode(response.body)),
      );

      for (Map<String, dynamic> item in state.sdkMap.data!['releases']) {
        if (state.sdkMap.data!['current_release']['stable'] == item['hash']) {
          state.copyWith(
            sdk: item['archive'],
          );
        }
      }
    } else {
      // If the server did not return a 200 OK response, throw an exception.
      throw Exception('Failed to Fetch API data.');
    }
  }
}
