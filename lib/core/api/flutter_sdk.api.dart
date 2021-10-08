// 🎯 Dart imports:
import 'dart:convert';

// 🐦 Flutter imports:
import 'package:flutter/widgets.dart';

// 📦 Package imports:
import 'package:http/http.dart' as http;

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/models/flutter_sdk.model.dart';
import 'package:manager/core/models/fluttermatic.model.dart';

class FlutterSDKNotifier with ChangeNotifier {
  FlutterSDK? _sdkMap;
  String? _sdk;
  FlutterSDK? get sdkMap => _sdkMap;
  String? get sdk => _sdk;
  Future<void> fetchSDKData(FluttermaticAPI? api) async {
    http.Response response = await http.get(Uri.parse(
        api!.data!['flutter']['base_url'] + api.data!['flutter'][platform]));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      _sdkMap = FlutterSDK.fromJson(
        jsonDecode(
          response.body,
        ),
      );
      notifyListeners();
      for (Map<String, dynamic> item in _sdkMap!.data!['releases']) {
        if (_sdkMap!.data!['current_release']['stable'] == item['hash']) {
          _sdk = item['archive'];
        }
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to Fetch API data.');
    }
  }
}
