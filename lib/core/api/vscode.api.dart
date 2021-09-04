import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:manager/core/libraries/models.dart';
import 'package:manager/secret.dart';

class VSCodeAPINotifier with ChangeNotifier {
  VSCodeAPI? _vscMap;
  String? _tagName, _sha;
  VSCodeAPI? get vscMap => _vscMap;
  String? get tagName => _tagName;
  String? get sha => _sha;
  Future<void> fetchVscAPIData() async {
    Map<String, String> _header = <String, String>{
      HttpHeaders.authorizationHeader: 'token ' + personalAccessToken,
      'Content-type': 'application/json',
      'Accept': 'application/vnd.github.v3+json',
    };
    http.Response response = await http.get(
      Uri.parse(
          'https://api.github.com/repos/microsoft/vscode/releases/latest'),
      headers: _header,
    );
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      _vscMap = VSCodeAPI.fromJson(
        content: jsonDecode(
          response.body,
        ),
      );
      _tagName = _vscMap!.data!['tag_name'];
      notifyListeners();
      http.Response gitResponse = await http.get(
          Uri.parse(
              'https://api.github.com/repos/microsoft/vscode/git/refs/tags/$_tagName'),
          headers: _header);
      if (gitResponse.statusCode == 200) {
        // If the server did return a 200 OK response,
        VSCodeAPI _gitVscMap = VSCodeAPI.fromJson(
          gitContent: jsonDecode(
            gitResponse.body,
          ),
        );
        _sha = _gitVscMap.gitData!['object']['sha'];
        notifyListeners();
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to Fetch API data.');
    }
  }
}
