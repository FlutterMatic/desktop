// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 📦 Package imports:
import 'package:fluttermatic/core/libraries/constants.dart';
import 'package:fluttermatic/core/libraries/services.dart';
import 'package:process_run/shell_run.dart';
import 'package:pub_semver/pub_semver.dart';

Future<Version?> getGitVersion() => getGitBinVersion();

Future<Version?> getGitBinVersion() async =>
    (await getGitBinInfo())?.gitVersion;

GitBinInfo? _gitBinInfo;

Future<GitBinInfo?> getGitBinInfo() async =>
    _gitBinInfo ??= await _getGitBinInfo();

/// Parse Git information
abstract class GitBinInfo {
  Version? get gitVersion;

  /// First line is sufficient
  static GitBinInfo? parseVersionOutput(String resultOutput) {
    Version? gitVersion;
    Iterable<String> output = LineSplitter.split(resultOutput)
        .join(' ')
        .split(' ')
        .map((String word) => word.trim())
        .where((String word) => word.isNotEmpty);
    bool foundGit = false;

    for (String word in output) {
      if (gitVersion == null) {
        if (foundGit) {
          try {
            if (word.contains('.windows')) {
              word = word.split('.windows')[0];
            }
            gitVersion = Version.parse(word);
          } catch (_, s) {
            logger.file(
                LogTypeTag.error, 'Failed to parse Git version: $word: $_',
                stackTraces: s);
          }
        } else if (word.toLowerCase().contains('git')) {
          foundGit = true;
        }
      }
    }
    if (gitVersion != null) {
      return GitBinInfoImpl(version: gitVersion);
    }
    return null;
  }
}

class GitBinInfoImpl extends GitBinInfo {
  Version? version;
  @override
  Version? get gitVersion => version;
  GitBinInfoImpl({this.version});
}

/// Get Git info.
/// Returns null if Git cannot be found in the path
Future<GitBinInfo?> _getGitBinInfo() async {
  /// `git --version` command information will be stored in
  /// [resultOutput].
  String? resultOutput;
  // git --version
  // git version 2.32.0.windows.1
  try {
    List<ProcessResult> gitResults = await shell.run('git --version');

    /// `git --version` outputs to stderr, so we need to check the first line.
    resultOutput = gitResults.first.stderr.toString().trim();

    /// If the output is empty,
    /// It means that the command logged the result in stdout.
    if (resultOutput.isEmpty) {
      resultOutput = gitResults.first.stdout.toString().trim();
    }

    /// returning the data.
    return GitBinInfo.parseVersionOutput(resultOutput);
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
