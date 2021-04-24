import 'package:flutter_installer/models/flutter_api.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

APICalls apiCalls = APICalls();

class APICalls {
  Future<FlutterReleases> flutterAPICall() async {
    if (win32) {
      http.Response? apiResponse = await http.get(APILinks.win32RelaseEndpoint);
      Map<String, dynamic> data = json.decode(apiResponse.body);
      return FlutterReleases.fromJson(data);
    } else if (mac) {
      http.Response? apiResponse = await http.get(APILinks.macRelaseEndpoint);
      Map<String, dynamic> data = json.decode(apiResponse.body);
      debugPrint(apiResponse.body);
      return FlutterReleases.fromJson(data);
    } else {
      http.Response? apiResponse = await http.get(APILinks.linuxRelaseEndpoint);
      Map<String, dynamic> data = json.decode(apiResponse.body);
      debugPrint(apiResponse.body);
      return FlutterReleases.fromJson(data);
    }
  }
}
