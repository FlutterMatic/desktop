// 🎯 Dart imports:
import 'dart:convert';

// 🐦 Flutter imports:
import 'package:flutter/widgets.dart';

// 📦 Package imports:
import 'package:http/http.dart' as http;

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/enum.dart';
import 'package:fluttermatic/core/models/fluttermatic.model.dart';
import 'package:fluttermatic/core/services/logs.dart';

class FlutterMaticAPINotifier with ChangeNotifier {
  // API Map
  FluttermaticAPI? _apiMap;
  FluttermaticAPI? get apiMap => _apiMap;

  // Progress
  Progress _progress = Progress.none;
  Progress get progress => _progress;

  Future<void> fetchAPIData() async {
    await logger.file(LogTypeTag.info,
        'Fetching Fluttermatic API data - Might be exponential back-off request.');

    _progress = Progress.downloading;
    notifyListeners();

    http.Response response = await http
        .get(Uri.parse('https://fluttermatic.herokuapp.com/api/data'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      _apiMap = FluttermaticAPI.fromJson(jsonDecode(response.body));
      _progress = Progress.done;
      notifyListeners();
    } else {
      // If the server did not return a 200 OK response, then throw an exception.
      throw Exception('Failed to Fetch API data.');
    }
  }
}
