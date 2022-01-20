// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 📦 Package imports:
import 'package:fluttermatic/core/libraries/services.dart';
import 'package:process_run/shell_run.dart';
import 'package:pub_semver/pub_semver.dart';

String? _flutterExecutablePath;

/// Resolved flutter path if found
String? get flutterExecutablePath =>
    _flutterExecutablePath ??= whichSync('flutter');

bool get isFlutterSupported => isFlutterSupportedSync;

/// true if flutter is supported
bool get isFlutterSupportedSync => flutterExecutablePath != null;

// to deprecate
Future<Version?> getFlutterVersion() => getFlutterBinVersion();

/// Get flutter version.
///
/// Returns null if flutter cannot be found in the path
Future<Version?> getFlutterBinVersion() async =>
    (await getFlutterBinInfo())?.version;

/// Get flutter channel. (dev, beta, master, stable)
///
/// Returns null if flutter cannot be found in the path
Future<String?> getFlutterBinChannel() async =>
    (await getFlutterBinInfo())?.channel;

FlutterBinInfo? _flutterBinInfo;

Future<FlutterBinInfo?> getFlutterBinInfo() async =>
    _flutterBinInfo ??= await _getFlutterBinInfo();

/// Parse flutter information
abstract class FlutterBinInfo {
  String? get channel;

  Version? get version;

  /// First line is sufficient
  static FlutterBinInfo? parseVersionOutput(String resultOutput) {
    Version? version;
    String? channel;
    List<String> output = LineSplitter.split(resultOutput)
        .join(' ')
        .split(' ')
        .map((String word) => word.trim())
        .where((String word) => word.isNotEmpty)
        .toList();
    // Take the first version string after flutter
    bool foundFlutter = false;
    bool foundChannel = false;

    for (String word in output) {
      if (version == null) {
        if (foundFlutter) {
          try {
            version = Version.parse(word);
          } catch (_, s) {
            logger.file(
                LogTypeTag.error, 'Failed to parse Flutter version: $word: $_',
                stackTraces: s);
          }
        } else if (word.toLowerCase().contains('flutter')) {
          foundFlutter = true;
        }
      } else if (channel == null) {
        if (foundChannel) {
          channel = word;
          // Done
          break;
        } else if (word.toLowerCase().contains('channel')) {
          foundChannel = true;
        }
      }
    }
    if (version != null && channel != null) {
      return FlutterBinInfoImpl(version: version, channel: channel);
    }
    return null;
  }
}

class FlutterBinInfoImpl implements FlutterBinInfo {
  @override
  final String? channel;

  @override
  final Version? version;

  FlutterBinInfoImpl({this.channel, this.version});
}

/// Get flutter info.
///
/// Not exposed yet
///
/// Returns null if flutter cannot be found in the path
Future<FlutterBinInfo?> _getFlutterBinInfo() async {
  // $ flutter --version
  // Flutter 1.7.8+hotfix.4 • channel stable • https://github.com/flutter/flutter.git
  // Framework • revision 20e59316b8 (8 weeks ago) • 2019-07-18 20:04:33 -0700
  // Engine • revision fee001c93f
  // Tools • Dart 2.4.0
  try {
    List<ProcessResult> results =
        await run('flutter --version', verbose: false);
    // Take from stderr first
    String resultOutput = results.first.stderr.toString().trim();
    if (resultOutput.isEmpty) {
      resultOutput = results.first.stdout.toString().trim();
    }
    return FlutterBinInfo.parseVersionOutput(resultOutput);
  } catch (_) {}
  return null;
}
