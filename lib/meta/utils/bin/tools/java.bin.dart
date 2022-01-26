// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 📦 Package imports:
import 'package:process_run/shell_run.dart';
import 'package:pub_semver/pub_semver.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/core/services/logs.dart';

Future<Version?> getJavaVersion() => getJavaBinVersion();

Future<Version?> getJavaBinVersion() async =>
    (await getJavaBinInfo())?.javaVersion;

JavaBinInfo? _javaBinInfo;

Future<JavaBinInfo?> getJavaBinInfo() async =>
    _javaBinInfo ??= await _getJavaBinInfo();

/// Parse java information
abstract class JavaBinInfo {
  Version? get javaVersion;

  /// First line is sufficient
  static JavaBinInfo? parseVersionOutput(String resultOutput) {
    Version? javaVersion;
    Iterable<String> output = LineSplitter.split(resultOutput)
        .join(' ')
        .split(' ')
        .map((String word) => word.trim())
        .where((String word) => word.isNotEmpty);
    bool foundJava = false;

    for (String word in output) {
      if (word.contains('_')) {
        word = word.replaceAll('_', '-').replaceAll('"', '');
      }
      if (javaVersion == null) {
        if (foundJava) {
          try {
            javaVersion = Version.parse(word.replaceAll('"', ''));
          } catch (_) {}
        } else if (word.toLowerCase().contains('java')) {
          foundJava = true;
        }
      }
    }
    if (javaVersion != null) {
      return JavaBinInfoImpl(version: javaVersion);
    }
    return null;
  }
}

class JavaBinInfoImpl extends JavaBinInfo {
  Version? version;
  @override
  Version? get javaVersion => version;
  JavaBinInfoImpl({this.version});
}

/// Get java info.
/// Returns null if java cannot be found in the path
Future<JavaBinInfo?> _getJavaBinInfo() async {
  /// `java -version` command information will be stored in
  /// [resultOutput].
  String? resultOutput;
  // java -version
  // java version "1.8.0_291"
  // Java(TM) SE Runtime Environment (build 1.8.0_291-b10)
  // Java HotSpot(TM) 64-Bit Server VM (build 25.291-b10, mixed mode)
  try {
    List<ProcessResult> javaResults = await shell.run('java -version');

    /// `java -version` outputs to stderr, so we need to check the first line.
    resultOutput = javaResults.first.stderr.toString().trim();

    /// If the output is empty,
    /// It means that the command logged the result in stdout.
    if (resultOutput.isEmpty) {
      resultOutput = javaResults.first.stdout.toString().trim();
    }

    /// returning the data.
    return JavaBinInfo.parseVersionOutput(resultOutput);
  }

  /// On [ShellException], Catch the error data to the logs file.
  on ShellException catch (shellException) {
    await logger.file(LogTypeTag.error, shellException.message);
  }

  /// On any other error, Catch the error data to the logs file.
  catch (err) {
    await logger.file(LogTypeTag.error, err.toString());
  }
  return null;
}
