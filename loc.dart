// ignore_for_file: avoid_print

import 'dart:io';

Future<void> main(List<String> args) async {
  String mostLines = '';
  int mostLinesTotal = 0;

  const List<String> scanDirs = [
    'lib',
    'test',
  ];

  int totalLines = 0;
  int totalLinesSkipped = 0;
  Map<String, int> extensionCounts = <String, int>{};

  for (String dir in scanDirs) {
    // Counts how many lines in total of all files in the current directory.
    List<FileSystemEntity> files =
        Directory('${Directory.current.path}\\$dir').listSync(recursive: true);

    for (FileSystemEntity file in files) {
      if (file is File) {
        try {
          String codeFile = await file.readAsString();

          int length = codeFile.split('\n').length;

          totalLines += length;

          if (length > mostLinesTotal) {
            mostLines = file.path;
            mostLinesTotal = length;
          }

          if (extensionCounts[file.path.split('.').last] == null) {
            extensionCounts[file.path.split('.').last] = 1;
          } else {
            extensionCounts[file.path.split('.').last] =
                extensionCounts[file.path.split('.').last]! + 1;
          }
        } catch (_) {
          totalLinesSkipped++;
        }
      }
    }
  }

  print('Total lines: $totalLines');
  print('Total files skipped: $totalLinesSkipped');

  print('Most lines file: $mostLines');
  print('Most lines file total lines: $mostLinesTotal');

  print('Extension counts:');

  // Prints the top 10 extensions and their counts.
  extensionCounts.keys.toList()
    ..sort((String a, String b) =>
        extensionCounts[b]!.compareTo(extensionCounts[a]!))
    ..take(10).forEach((String extension) {
      print(
          ' - ${extension.toUpperCase()}: ${extensionCounts[extension]} file(s)');
    });
}
