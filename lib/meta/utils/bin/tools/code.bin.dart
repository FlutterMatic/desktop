// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 📦 Package imports:
import 'package:process_run/shell_run.dart';
import 'package:pub_semver/pub_semver.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/services/logs.dart';

Future<Version?> getVSCVersion() => getVSCBinVersion();

Future<Version?> getVSCBinVersion() async =>
    (await getVSCBinInfo())?.vscVersion;

VSCBinInfo? _vscBinInfo;

Future<VSCBinInfo?> getVSCBinInfo() async =>
    _vscBinInfo ??= await _getVSCBinInfo();

/// Parse Visual Studio Code information
abstract class VSCBinInfo {
  Version? get vscVersion;

  /// First line is sufficient
  static Future<VSCBinInfo?> parseVersionOutput(String? resultOutput) async {
    if (resultOutput == null) {
      await logger.file(LogTypeTag.error, 'VSCode result : $resultOutput');
      return null;
    }
    Version? vscVersion;
    List<String?>? output =
        LineSplitter.split(resultOutput).join(' ').split(' ');
    vscVersion = Version.parse(output[0]!);
    return VSCBinInfoImpl(version: vscVersion);
  }
}

class VSCBinInfoImpl extends VSCBinInfo {
  Version? version;
  @override
  Version? get vscVersion => version;
  VSCBinInfoImpl({this.version});
}

/// Get Visual Studio Code info.
/// Returns null if Visual Studio Code cannot be found in the path
Future<VSCBinInfo?> _getVSCBinInfo() async {
  /// `code -v` command information will be stored in
  /// [resultOutput].
  String? resultOutput;
  // code -v
  // 1.58.0
  // 2d23c42a936db1c7b3b06f918cde29561cc47cd6
  // x64
  try {
    List<ProcessResult> vscResults = await shell.run('code -v');

    /// `code -v` outputs to stderr, so we need to check the first line.
    resultOutput = vscResults.first.stderr.toString().trim();

    /// If the output is empty,
    /// It means that the command logged the result in stdout.
    if (resultOutput.isEmpty) {
      resultOutput = vscResults.first.stdout.toString().trim();
    }

    /// returning the data.
    return VSCBinInfo.parseVersionOutput(resultOutput);
  }

  /// On [ShellException], Catch the error data to the logs file.
  on ShellException catch (_, s) {
    await logger.file(LogTypeTag.error, _.message, stackTraces: s);
  }

  /// On any other error, Catch the error data to the logs file.
  catch (err) {
    await logger.file(LogTypeTag.error, err.toString());
  }
  return null;
}
