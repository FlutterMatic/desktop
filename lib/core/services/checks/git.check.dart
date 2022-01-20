// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';
import 'package:provider/provider.dart';
import 'package:pub_semver/src/version.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/enum.dart';
import 'package:fluttermatic/app/constants/shared_pref.dart';
import 'package:fluttermatic/core/libraries/models.dart';
import 'package:fluttermatic/core/libraries/notifiers.dart';
import 'package:fluttermatic/core/libraries/services.dart';
import 'package:fluttermatic/meta/utils/bin/tools/git.bin.dart';
import 'package:fluttermatic/meta/utils/shared_pref.dart';

/// [GitNotifier] class is a [ChangeNotifier]
/// for Git checks.
class GitNotifier extends ChangeNotifier {
  /// [gitVersion] value holds git version information
  Version? gitVersion;

  /// [gitDownloadLink] value holds git latest download link.
  String? gitDownloadLink;
  Progress _progress = Progress.none;
  Progress get progress => _progress;

  /// Check git exists in the system or not.
  Future<void> checkGit(BuildContext context, FluttermaticAPI? api) async {
    try {
      _progress = Progress.started;
      notifyListeners();

      /// Make a fake delay of 1 second such that UI looks cool.
      await Future<dynamic>.delayed(const Duration(seconds: 1));
      Directory _dir = await getApplicationSupportDirectory();
      _progress = Progress.checking;
      notifyListeners();
      String? _gitPath = await which('git');
      if (_gitPath == null) {
        await logger.file(
            LogTypeTag.warning, 'Git not installed in the system.');

        await logger.file(LogTypeTag.info, 'Downloading Git');
        if (Platform.isWindows) {
          /// Application supporting Directory
          http.Response response = await http.get(Uri.parse(api!.data!['git']));
          if (response.statusCode == 200) {
            // If the server did return a 200 OK response,
            GitAPI gitData = GitAPI.fromJson(
              jsonDecode(
                response.body,
              ),
            );
            gitData.data!['assets'].forEach((dynamic asset) {
              if (asset['content_type'] == 'application/x-bzip2' &&
                  asset['name'].contains('64-bit.')) {
                gitDownloadLink = asset['browser_download_url'];
              }
            });
          } else {
            throw Exception('Failed to Fetch data - ${response.statusCode}');
          }

          /// Check for git Directory to extract Git files
          // bool gitDir = await checkDir('C:\\fluttermatic', subDirName: 'git');

          /// If [gitDir] is false, then create a temporary directory.
          // if (!gitDir) {
          //   await Directory('C:\\fluttermatic\\git').create(recursive: true);
          //   await logger.file(LogTypeTag.info, 'Created git directory.');
          // }
          _progress = Progress.downloading;
          notifyListeners();

          /// Downloading Git.
          await context.read<DownloadNotifier>().downloadFile(
              gitDownloadLink!, 'git.tar.bz2', _dir.path + '\\tmp');

          _progress = Progress.extracting;
          notifyListeners();

          /// Extract java from compressed file.
          bool _gitExtracted = await unzip(
            _dir.path + '\\tmp\\' + 'git.tar.bz2',
            'C:\\fluttermatic\\git',
          );
          if (_gitExtracted) {
            await logger.file(LogTypeTag.info, 'Git extraction was successful');
          } else {
            await logger.file(LogTypeTag.error, 'Git extraction failed.');
          }

          /// Appending path to env
          bool _isGitPathSet =
              await setPath('C:\\fluttermatic\\git\\bin', _dir.path);

          if (_isGitPathSet) {
            await SharedPref()
                .pref
                .setString(SPConst.gitPath, 'C:\\fluttermatic\\git\\bin');
            _progress = Progress.done;
            notifyListeners();
            await logger.file(LogTypeTag.info, 'Git set to path');
          } else {
            _progress = Progress.failed;
            notifyListeners();
            await logger.file(LogTypeTag.error, 'Git set to path failed');
          }
        }

        /// MacOS platform
        else if (Platform.isMacOS) {
          _progress = Progress.downloading;
          notifyListeners();
          await run('brew install git', verbose: false);
        }

        /// Linux distros
        else {
          _progress = Progress.downloading;
          notifyListeners();
          await run('sudo apt-get install git', verbose: false);
        }
      }

      /// Else we need to get version information.
      else if (!SharedPref().pref.containsKey(SPConst.gitPath) ||
          !SharedPref().pref.containsKey(SPConst.gitVersion)) {
        /// Make a fake delay of 1 second such that UI looks cool.
        await Future<dynamic>.delayed(const Duration(seconds: 1));
        await logger.file(LogTypeTag.info, 'Git found at - $_gitPath');
        await SharedPref().pref.setString(SPConst.gitPath, _gitPath);

        /// Make a fake delay of 1 second such that UI looks cool.
        await Future<dynamic>.delayed(const Duration(seconds: 1));
        gitVersion = await getGitBinVersion();
        versions.git = gitVersion.toString();
        await logger.file(LogTypeTag.info, 'Git version : ${versions.git}');
        await SharedPref().pref.setString(SPConst.gitVersion, versions.git!);
        _progress = Progress.done;
        notifyListeners();
      } else {
        await logger.file(
            LogTypeTag.info, 'Loading git details from shared preferences');
        _gitPath = SharedPref().pref.getString(SPConst.gitPath);
        await logger.file(LogTypeTag.info, 'Git found at - $_gitPath');
        versions.git = SharedPref().pref.getString(SPConst.gitVersion);
        await logger.file(LogTypeTag.info, 'Git version : ${versions.git}');
        _progress = Progress.done;
        notifyListeners();
      }
    } on ShellException catch (shellException, s) {
      _progress = Progress.failed;
      notifyListeners();
      await logger.file(LogTypeTag.error, shellException.message,
          stackTraces: s);
    } catch (_, s) {
      _progress = Progress.failed;
      notifyListeners();
      await logger.file(LogTypeTag.error, _.toString(), stackTraces: s);
    }
  }
}
