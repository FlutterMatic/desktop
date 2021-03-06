// 🎯 Dart imports:
import 'dart:io';

// 📦 Package imports:
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell_run.dart';
import 'package:pub_semver/pub_semver.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/services/logs.dart';

Future<Version?> getAStudioVersion() => getAStudioBinVersion();

Future<Version?> getAStudioBinVersion() async =>
    (await getAndroidStudioBinInfo())?.studioVersion;

AndroidStudioBinInfo? _studioBinInfo;

Future<AndroidStudioBinInfo?> getAndroidStudioBinInfo() async =>
    _studioBinInfo ??= await _getAndroidStudioBinInfo();

/// Parse java information
abstract class AndroidStudioBinInfo {
  Version? get studioVersion;

  /// First line is sufficient
  static AndroidStudioBinInfo? parseVersionOutput(String resultOutput) {
    Version? studioVersion;
    try {
      studioVersion = Version.parse(resultOutput);
      return AndroidStudioBinInfoImpl(version: studioVersion);
    } on FormatException catch (formatException) {
      logger.file(
          LogTypeTag.error, 'Format Exception: ${formatException.toString()}');
      return null;
    } catch (_, s) {
      logger.file(LogTypeTag.error, _.toString(), stackTraces: s);
      return null;
    }
  }
}

class AndroidStudioBinInfoImpl extends AndroidStudioBinInfo {
  Version? version;
  @override
  Version? get studioVersion => version;
  AndroidStudioBinInfoImpl({this.version});
}

/// Get Android studio info.
/// Returns null if java cannot be found in the path
Future<AndroidStudioBinInfo?> _getAndroidStudioBinInfo() async {
  String? resultOutput;
  try {
    String supportPath =
        (await getTemporaryDirectory()).path.replaceAll('Temp', 'Google');
    await Directory(supportPath)
        .list(recursive: false)
        .forEach((FileSystemEntity f) {
      if (f.path.contains('AndroidStudio')) {
        resultOutput =
            f.path.split('\\').last.replaceAll(RegExp('[^\\d.]'), '');
      }
    });

    /// returning the data.
    return AndroidStudioBinInfo.parseVersionOutput(resultOutput!);
  }

  /// On [ShellException], Catch the error data to the logs file.
  on ShellException catch (_, s) {
    await logger.file(LogTypeTag.error, _.message, stackTraces: s);
  }

  /// On any other error, Catch the error data to the logs file.
  catch (_, s) {
    await logger.file(LogTypeTag.error, _.toString(), stackTraces: s);
  }
  return null;
}
