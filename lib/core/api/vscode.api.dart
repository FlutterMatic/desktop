import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:manager/core/libraries/models.dart';

class VSCodeAPINotifier with ChangeNotifier {
  VSCodeAPI? _vscMap;
  String? _tag_name, _sha;
  VSCodeAPI? get vscMap => _vscMap;
  String? get tag_name => _tag_name;
  String? get sha => _sha;
  Future<void> fetchAPIData() async {
    http.Response response = await http.get(Uri.parse(
        'https://api.github.com/repos/microsoft/vscode/releases/latest'));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      _vscMap = VSCodeAPI.fromJson(
        content: jsonDecode(
          response.body,
        ),
      );
      _tag_name = _vscMap!.data!['tag_name'];
      notifyListeners();
      http.Response gitResponse = await http.get(Uri.parse(
          'https://api.github.com/repos/microsoft/vscode/git/refs/tags/$_tag_name'));
      if (gitResponse.statusCode == 200) {
        // If the server did return a 200 OK response,
        VSCodeAPI _gitvscMap = VSCodeAPI.fromJson(
          gitContent: jsonDecode(
            gitResponse.body,
          ),
        );
        _sha = _gitvscMap.gitData!['object']['sha'];
        notifyListeners();
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to Fetch data');
    }
  }
}
