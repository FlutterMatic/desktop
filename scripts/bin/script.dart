// Dart imports:
import 'dart:io';

// Project imports:
import 'src/build.dart';
import 'src/build_utils/build.dart';
import 'utils.dart';

// Gets the fluttermatic_desktop path from the current path ignoring the last
// element(s) of the path.
late String fluttermaticDesktopPath;

Future<void> main(List<String> args) async {
  if (Platform.isMacOS) {
    print(errorPen('This script is not yet supported on macOS.'));
    exit(1);
  }

  if (Directory.current.path.endsWith('scripts')) {
    fluttermaticDesktopPath =
        (Directory.current.path.split('\\')..removeLast()).join('\\');
  } else {
    fluttermaticDesktopPath = Directory.current.path;
  }

  if (args.isEmpty) {
    print(greenPen('Building app in Release mode...'));

    // Build the app in release mode.
    await buildAppWithMode(BuildMode.release);

    return;
  }

  if (args.length > 1) {
    print(errorPen(
        'Too many arguments provided. Run --help for more information.'));
    exit(1);
  }

  if (args.first == '--help' || args.first == '-h') {
    print(infoPen(helpMessage));
    return;
  }

  if (args.first == '--version' || args.first == '-v') {
    print(infoPen(versionMessage));
    return;
  }

  if (args.first.startsWith('--mode') || args.first.startsWith('-m')) {
    // Validate the mode argument.
    if (!validModes.contains(args.first.split('=')[1].toLowerCase().trim())) {
      print(errorPen('Invalid build mode provided.'));
      exit(1);
    }

    switch (args.first.split('=')[1].toLowerCase().trim()) {
      case 'debug':
        print(greenPen('Building app in Debug mode...'));

        // Build the app in debug mode.
        await buildAppWithMode(BuildMode.debug);

        return;
      case 'profile':
        print(greenPen('Building app in Profile mode...'));

        // Build the app in profile mode.
        await buildAppWithMode(BuildMode.profile);

        return;
      case 'release':
        print(greenPen('Building app in Release mode...'));

        // Build the app in release mode.
        await buildAppWithMode(BuildMode.release);

        return;
      default:
        print(errorPen('Invalid build mode provided.'));
        exit(1);
    }
  }

  print(warningPen(
      'Invalid argument provided. Run --help for more information.'));
  exit(1);
}
