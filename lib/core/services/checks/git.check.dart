import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:manager/core/libraries/models.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/meta/utils/bin/git.bin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
// ignore: implementation_imports
import 'package:pub_semver/src/version.dart';

/// [GitNotifier] class is a [ChangeNotifier]
/// for Git checks.
class GitNotifier extends ChangeNotifier {

  /// [gitVersion] value holds git version information
  Version? gitVersion;

  /// [gitDownloadLink] value holds git latest download link.
  String? gitDownloadLink;

  /// Check git exists in the system or not.
  Future<void> checkGit(BuildContext context, FluttermaticAPI? api) async {
    try {
      /// Make a fake delay of 1 second such that UI looks cool.
      await Future<dynamic>.delayed(const Duration(seconds: 1));
      String? gitPath = await which('git');
      Directory dir = await getApplicationSupportDirectory();
      if (gitPath == null) {
        await logger.file(
            LogTypeTag.WARNING, 'Git not installed in the system.');
        await logger.file(LogTypeTag.INFO, 'Downloading Git');
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

          /// Check for temporary Directory to download files
          bool tmpDir = await checkDir(dir.path, subDirName: 'tmp');

          /// Check for git Directory to extract Git files
          bool gitDir = await checkDir('C:\\fluttermatic', subDirName: 'git');

          /// If [tmpDir] is false, then create a temporary directory.
          if (!tmpDir) {
            await Directory('${dir.path}\\tmp').create();
            await logger.file(
                LogTypeTag.INFO, 'Created tmp directory while checking git');
          }

          /// If [gitDir] is false, then create a temporary directory.
          if (!gitDir) {
            await Directory('C:\\fluttermatic\\git').create();
            await logger.file(LogTypeTag.INFO, 'Created git directory.');
          }

          /// Downloading Git.
          await context.read<DownloadNotifier>().downloadFile(
                gitDownloadLink!,
                'git.tar.bz2',
                dir.path + '\\tmp\\',
                progressBarColor: Colors.black,
              );

          /// Extract java from compressed file.
          bool gitExtracted = await unzip(
            dir.path + '\\tmp\\' + 'git.tar.bz2',
            'C:\\fluttermatic\\git',
          );
          if (gitExtracted) {
            await logger.file(
                LogTypeTag.INFO, 'Git extraction was successfull');
          } else {
            await logger.file(LogTypeTag.ERROR, 'Git extraction failed.');
          }

          /// Appending path to env
          bool isGitPathSet =
              await setPath('C:\\fluttermatic\\git\\bin\\', dir.path);
          if (isGitPathSet) {
            await logger.file(LogTypeTag.INFO, 'Git set to path');
          } else {
            await logger.file(LogTypeTag.ERROR, 'Git set to path failed');
          }
        }

        /// MacOS platform
        else if (Platform.isMacOS) {
          await run('brew install git', verbose: false);
        }

        /// Linux distros
        else {
          await run('sudo apt-get install git', verbose: false);
        }
      }

      /// Else we need to get version information.
      else {
        /// Make a fake delay of 1 second such that UI looks cool.
        await Future<dynamic>.delayed(const Duration(seconds: 1));
        await logger.file(LogTypeTag.INFO, 'Git found at - $gitPath');

        /// Make a fake delay of 1 second such that UI looks cool.
        await Future<dynamic>.delayed(const Duration(seconds: 1));
        gitVersion = await getGitBinVersion();
        versions.git = gitVersion.toString();
        await logger.file(LogTypeTag.INFO, 'Git version : ${versions.git}');
      }
    } on ShellException catch (shellException) {
      await logger.file(LogTypeTag.ERROR, shellException.message);
    } catch (err) {
      await logger.file(LogTypeTag.ERROR, err.toString());
    }
  }
}