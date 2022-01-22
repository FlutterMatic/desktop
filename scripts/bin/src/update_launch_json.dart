// Dart imports:
import 'dart:convert';
import 'dart:io';

// Project imports:
import '../script.dart';
import 'version.dart';

Future<void> updateLaunchJson(Version version) async {
  File _file = File('$fluttermaticDesktopPath\\.vscode\\launch.json');

  List<String> _lines = await _file.readAsLines();

  // Remove the comments from the [_lines].
  _lines =
      _lines.where((String line) => !line.trim().startsWith('//')).toList();

  Map<String, dynamic> _contents = jsonDecode(_lines.join(''));

  List<String> _args = (_contents['configurations'][0]['args'] as List<dynamic>)
      .map((dynamic e) => e.toString())
      .toList();

  List<String> _newArgs = <String>[];

  bool _foundReleaseType = false;
  bool _foundCurrentVersion = false;

  String _dartDefine = '--dart-define';
  String _releaseType = 'RELEASE_TYPE=${version.releaseType.name}';
  String _currentVersion =
      'CURRENT_VERSION=${version.major}.${version.minor}.${version.patch}-${version.releaseType.name}';

  for (String arg in _args) {
    if (arg == _dartDefine) {
      continue;
    }
    if (arg.startsWith('RELEASE_TYPE=')) {
      _foundReleaseType = true;
      _newArgs.add(_dartDefine);
      _newArgs.add(_releaseType);
    } else if (arg.startsWith('CURRENT_VERSION=')) {
      _foundCurrentVersion = true;
      _newArgs.add(_dartDefine);
      _newArgs.add(_currentVersion);
    } else {
      _newArgs.add(arg);
    }
  }

  if (!_foundReleaseType) {
    _newArgs.add(_dartDefine);
    _newArgs.add(_releaseType);
  }

  if (!_foundCurrentVersion) {
    _newArgs.add(_dartDefine);
    _newArgs.add(_currentVersion);
  }

  _contents['configurations'][0]['args'] = _newArgs;

  await _file.writeAsString(jsonEncode(_contents));
}
