// 🎯 Dart imports:
import 'dart:convert';

// 🐦 Flutter imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermatic/core/notifiers/models/state/api/vscode_api.dart';

// 📦 Package imports:
import 'package:http/http.dart' as http;

// 🌎 Project imports:
import 'package:fluttermatic/core/models/vscode.dart';

class VSCodeAPINotifier extends StateNotifier<VSCodeAPIState> {
  final Reader read;

  VSCodeAPINotifier(this.read) : super(VSCodeAPIState.initial());

  /// Fetches the Visual Studio Code API data from GitHub. This will get the
  /// latest release information.
  ///
  /// Sha data will also be included but updated in a separate state batch
  /// because we are making a different request to retrieve it.
  Future<void> fetchVscAPIData() async {
    const Map<String, String> header = <String, String>{
      'Content-type': 'application/json',
      'Accept': 'application/vnd.github.v3+json',
    };

    http.Response response = await http.get(
      Uri.parse(
          'https://api.github.com/repos/microsoft/vscode/releases/latest'),
      headers: header,
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response.
      VSCodeAPI decodedAPIData =
          VSCodeAPI.fromJson(content: jsonDecode(response.body));

      state = state.copyWith(
        vscMap: decodedAPIData,
        tagName: decodedAPIData.data!['tag_name'],
      );

      http.Response gitResponse = await http.get(
          Uri.parse(
              'https://api.github.com/repos/microsoft/vscode/git/refs/tags/${state.tagName}'),
          headers: header);

      if (gitResponse.statusCode == 200) {
        // If the server did return a 200 OK response,
        VSCodeAPI gitVscMap =
            VSCodeAPI.fromJson(gitContent: jsonDecode(gitResponse.body));

        state = state.copyWith(
          sha: gitVscMap.gitData!['object']['sha'],
        );
      }
    } else {
      // If the server did not return a 200 OK response, throw an exception.
      throw Exception('Failed to Fetch API data.');
    }
  }
}
