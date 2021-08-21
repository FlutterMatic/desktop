import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:manager/app/constants/enum.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/core/models/fluttermatic.model.dart';

class FlutterMaticAPINotifier with ChangeNotifier {
  FluttermaticAPI? _apiMap;
  FluttermaticAPI? get apiMap => _apiMap;
  Progress _progress = Progress.none;
  Progress get progress => _progress;
  Future<void> fetchAPIData() async {
    await logger.file(LogTypeTag.INFO, 'Fetching Fluttermatic API data');
    _progress = Progress.downloading;
    notifyListeners();
    http.Response response = await http
        .get(Uri.parse('https://fluttermatic.herokuapp.com/api/data'));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      _apiMap = FluttermaticAPI.fromJson(
        jsonDecode(
          response.body,
        ),
      );
      _progress = Progress.done;
      notifyListeners();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to Fetch API data.');
    }
  }
}
