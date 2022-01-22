// Dart imports:
import 'dart:io';

// Project imports:
import '../../script.dart';
import '../../utils.dart';

Future<void> moveBuildOutput(String buildOutputPath, String outputPath) async {
  try {
    Directory _buildDir = Directory(buildOutputPath);
    Directory _outputDir = Directory(outputPath);

    if (!await _buildDir.exists()) {
      print(errorPen('Error finding the build output directory'));
      exit(1);
    }

    // If the release folder already exists from a previous build, delete it.
    if (await _outputDir.exists()) {
      await _outputDir.delete(recursive: true);
    }

    // Create the output directory if it doesn't exist
    await _outputDir.create(recursive: true);

    // Copies the build output to the output directory
    await shell
        .cd(fluttermaticDesktopPath)
        .run('Xcopy $buildOutputPath $outputPath /E/H/C/I');

    print(infoPen('You can find the build output in $outputPath'));
  } catch (_) {
    print(errorPen('Error moving build output'));
    exit(1);
  }
}
