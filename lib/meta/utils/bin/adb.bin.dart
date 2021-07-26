import 'dart:convert';
import 'dart:io';

import 'package:manager/core/services/logs.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:process_run/src/shell.dart';

Future<Version?> getADBVersion() => getADBBinVersion();

Future<Version?> getADBBinVersion() async =>
    (await getADBBinInfo())?.adbVersion;

ADBBinInfo? _adbBinInfo;

Future<ADBBinInfo?> getADBBinInfo() async =>
    _adbBinInfo ??= await _getADBBinInfo();

/// Parse ADB information
abstract class ADBBinInfo {
  Version? get adbVersion;

  /// First line is sufficient
  static ADBBinInfo? parseVersionOutput(String resultOutput) {
    Version? adbVersion;
    Iterable<String> output = LineSplitter.split(resultOutput)
        .join(' ')
        .split(' ')
        .map((String word) => word.trim())
        .where((String word) => word.isNotEmpty);
    bool foundADB = false;

    for (String word in output) {
      if (adbVersion == null) {
        if (foundADB) {
          try {
            adbVersion = Version.parse(word);
          } catch (_) {}
        } else if (word.toLowerCase().contains('bridge')) {
          foundADB = true;
        }
      }
    }
    if (adbVersion != null) {
      return ADBBinInfoImpl(version: adbVersion);
    }
    return null;
  }
}

class ADBBinInfoImpl extends ADBBinInfo {
  Version? version;
  @override
  Version? get adbVersion => version;
  ADBBinInfoImpl({this.version});
}

/// Get ADB info.
/// Returns null if ADB cannot be found in the path
Future<ADBBinInfo?> _getADBBinInfo() async {
  /// `adb version` command information will be stored in
  /// [resultOutput].
  String? resultOutput;
  // adb version
  // Android Debug Bridge version 1.0.41
  // Version 31.0.2-7242960
  // Installed as C:\Users\yaswa\AppData\Local\Android\Sdk\platform-tools\adb.exe
  try {
    List<ProcessResult> adbResults = await run('adb version', verbose: false);

    /// `adb version` outputs to stderr, so we need to check the first line.
    resultOutput = adbResults.first.stderr.toString().trim();

    /// If the output is empty,
    /// It means that the command logged the result in stdout.
    if (resultOutput.isEmpty) {
      resultOutput = adbResults.first.stdout.toString().trim();
    }

    /// returning the data.
    return ADBBinInfo.parseVersionOutput(resultOutput);
  }

  /// On [ShellException], Catch the error data to the logs file.
  on ShellException catch (shellException) {
    await logger.file(LogTypeTag.ERROR, shellException.message);
  }

  /// On any other error, Catch the error data to the logs file.
  catch (err) {
    await logger.file(LogTypeTag.ERROR, err.toString());
  }
  return null;
}