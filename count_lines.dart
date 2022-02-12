// We can fancy with the number of lines we have. Just don't be *too* fancy.

// ignore_for_file: avoid_print

import 'dart:io';

Future<void> main(List<String> args) async {
  String _mostLines = '';
  int _mostLinesTotal = 0;

  // Counts how many lines in total of all files in the current directory.
  List<FileSystemEntity> _files =
      Directory(Directory.current.path + '\\lib').listSync(recursive: true);

  int _totalLines = 0;
  int _totalLinesSkipped = 0;

  Map<String, int> _extensionCounts = <String, int>{};

  for (FileSystemEntity _file in _files) {
    if (_file is File) {
      try {
        String _codeFile = await _file.readAsString();

        int _length = _codeFile.split('\n').length;

        _totalLines += _length;

        if (_length > _mostLinesTotal) {
          _mostLines = _file.path;
          _mostLinesTotal = _length;
        }

        if (_extensionCounts[_file.path.split('.').last] == null) {
          _extensionCounts[_file.path.split('.').last] = 1;
        } else {
          _extensionCounts[_file.path.split('.').last] =
              _extensionCounts[_file.path.split('.').last]! + 1;
        }
      } catch (_) {
        _totalLinesSkipped++;
      }
    }
  }

  print('Total lines: $_totalLines');
  print('Total files skipped: $_totalLinesSkipped');

  print('Most lines file: $_mostLines');
  print('Most lines total lines: $_mostLinesTotal');

  print('Extension counts:');
  // Prints the top 10 extensions and their counts.
  _extensionCounts.keys.toList()
    ..sort((String a, String b) =>
        _extensionCounts[b]!.compareTo(_extensionCounts[a]!))
    ..take(10).forEach((String _extension) {
      print(
          ' - ${_extension.toUpperCase()}: ${_extensionCounts[_extension]} file(s)');
    });
}
