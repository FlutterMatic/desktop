// 🎯 Dart imports:
import 'dart:convert';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// 🌎 Project imports:
import 'package:fluttermatic/core/models/api/fluttermatic.dart';
import 'package:fluttermatic/core/notifiers/models/state/api/fm_api.dart';
import 'package:fluttermatic/core/services/logs.dart';

class FlutterMaticAPINotifier extends StateNotifier<FlutterMaticAPIState> {
  final Ref ref;

  FlutterMaticAPINotifier(this.ref) : super(FlutterMaticAPIState.initial());

  /// Fetch the FlutterMatic api data from the API.
  ///
  /// This can be called multiple times, therefore, this is why "exponential
  /// back-off" might be logged. If it has been logged more than once then
  /// this means that this function has been called more than once, making
  /// more than one API request.
  Future<void> fetchAPIData() async {
    await logger.file(LogTypeTag.info,
        'Fetching FlutterMatic API data - Might be exponential back-off request.');

    http.Response response = await http
        .get(Uri.parse('https://fluttermatic.herokuapp.com/api/data'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      state = state.copyWith(
        apiMap: FlutterMaticAPI.fromJson(jsonDecode(response.body)),
      );
    } else {
      // If the server did not return a 200 OK response, throw an exception.
      throw Exception('Failed to Fetch API data.');
    }
  }
}
