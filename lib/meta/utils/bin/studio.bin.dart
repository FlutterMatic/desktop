import 'package:manager/core/services/logs.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:process_run/src/shell.dart';

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

    return null;
  }
}

class AndroidStudioBinInfoImpl extends AndroidStudioBinInfo {
  Version? version;
  @override
  Version? get studioVersion => version;
  AndroidStudioBinInfoImpl({this.version});
}

/// Get java info.
/// Returns null if java cannot be found in the path
Future<AndroidStudioBinInfo?> _getAndroidStudioBinInfo() async {
  /// `java -version` command information will be stored in
  /// [resultOutput].
  String? resultOutput;
  try {
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
