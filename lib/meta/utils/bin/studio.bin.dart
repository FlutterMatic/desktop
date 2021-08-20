import 'package:path_provider/path_provider.dart';
import 'package:manager/core/services/logs.dart';
import 'package:process_run/shell_run.dart';
import 'package:pub_semver/pub_semver.dart';
import 'dart:io';

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
      studioVersion = Version.parse('$resultOutput.0');
      return AndroidStudioBinInfoImpl(version: studioVersion);
    } on FormatException catch (formatException) {
      logger.file(
          LogTypeTag.ERROR, 'Format Exception : ${formatException.toString()}');
      return null;
    } catch (e) {
      logger.file(LogTypeTag.ERROR, e.toString());
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
        .list(recursive: true)
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
  on ShellException catch (shellException) {
    await logger.file(LogTypeTag.ERROR, shellException.message);
  }

  /// On any other error, Catch the error data to the logs file.
  catch (err) {
    await logger.file(LogTypeTag.ERROR, err.toString());
  }
  return null;
}
