// Package imports:
import 'package:ansicolor/ansicolor.dart';
import 'package:process_run/shell.dart';

// Color utilities for showing styled text in the CLI.
final AnsiPen errorPen = AnsiPen()
  ..red(bg: true)
  ..rgb(r: 0, g: 0, b: 0);
final AnsiPen warningPen = AnsiPen()
  ..yellow(bg: true)
  ..rgb(r: 0, g: 0, b: 0);
final AnsiPen infoPen = AnsiPen()..blue(bold: true);
final AnsiPen whitePen = AnsiPen()
  ..rgb(r: 255, g: 192, b: 203, bg: true)
  ..rgb(r: 0, g: 0, b: 0);
final AnsiPen purplePen = AnsiPen()
  ..magenta(bg: true, bold: true)
  ..rgb(r: 0, g: 0, b: 0);
final AnsiPen greenPen = AnsiPen()
  ..green(bg: true, bold: true)
  ..rgb(r: 0, g: 0, b: 0);

final Shell shell = Shell(
  verbose: false,
  commandVerbose: false,
  commentVerbose: false,
);

const String helpMessage = '''
Usage: script [options] [script]

Options:
  --help, -h              Print this message.
  --version, -v           Print the version number.has finished.
  --mode, -m              Build the app in the specified mode. Default is Release. Options: Debug, Profile, Release.
''';

String versionMessage = '''
Script version: 0.0.1
''';

const List<String> validModes = <String>['debug', 'profile', 'release'];
