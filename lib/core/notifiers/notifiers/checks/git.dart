// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/enum.dart';
import 'package:fluttermatic/app/shared_pref.dart';
import 'package:fluttermatic/bin/git.dart';
import 'package:fluttermatic/core/models/tools/git.dart';
import 'package:fluttermatic/core/notifiers/models/state/api/flutter_sdk.dart';
import 'package:fluttermatic/core/notifiers/models/state/checks/git.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/general/shared_pref.dart';

class GitNotifier extends StateNotifier<GitState> {
  final Ref ref;

  GitNotifier(this.ref) : super(GitState.initial());

  /// Check git exists in the system or not.
  Future<void> checkGit() async {
    String? gitDownloadLink;

    try {
      FlutterSDKState flutterSdkState = ref.watch(flutterSdkAPIStateNotifier);

      String drive = ref.watch(spaceStateController).drive;

      state = state.copyWith(
        progress: Progress.started,
      );

      Directory dir = await getApplicationSupportDirectory();

      state = state.copyWith(
        progress: Progress.checking,
      );

      String? gitPath = await which('git');

      if (gitPath == null) {
        await logger.file(
            LogTypeTag.warning, 'Git not installed in the system.');

        await logger.file(LogTypeTag.info, 'Downloading Git');

        if (Platform.isWindows) {
          /// Application supporting Directory
          http.Response response =
              await http.get(Uri.parse(flutterSdkState.sdkMap.data!['git']));
          if (response.statusCode == 200) {
            // If the server did return a 200 OK response,
            GitAPI gitData = GitAPI.fromJson(jsonDecode(response.body));
            gitData.data!['assets'].forEach((dynamic asset) {
              if (asset['content_type'] == 'application/x-bzip2' &&
                  asset['name'].contains('64-bit.')) {
                gitDownloadLink = asset['browser_download_url'];
              }
            });
          } else {
            throw Exception('Failed to Fetch data - ${response.statusCode}');
          }

          state = state.copyWith(
            progress: Progress.downloading,
          );

          /// Downloading Git.
          await ref.watch(downloadStateController.notifier).downloadFile(
              gitDownloadLink!, 'git.tar.bz2', '${dir.path}\\tmp');

          state = state.copyWith(
            progress: Progress.extracting,
          );

          /// Extract java from compressed file.
          bool gitExtracted = await ref.watch(fileStateNotifier.notifier).unzip(
              '${dir.path}\\tmp\\git.tar.bz2', '$drive:\\fluttermatic\\git');

          if (gitExtracted) {
            await logger.file(LogTypeTag.info, 'Git extraction was successful');
          } else {
            await logger.file(LogTypeTag.error, 'Git extraction failed.');
          }

          /// Appending path to env
          bool isGitPathSet = await ref
              .watch(fileStateNotifier.notifier)
              .setPath('$drive:\\fluttermatic\\git\\bin', dir.path);

          if (isGitPathSet) {
            await SharedPref()
                .pref
                .setString(SPConst.gitPath, '$drive:\\fluttermatic\\git\\bin');

            state = state.copyWith(
              progress: Progress.done,
            );
            await logger.file(LogTypeTag.info, 'Git set to path');
          } else {
            state = state.copyWith(
              progress: Progress.failed,
            );
            await logger.file(LogTypeTag.error, 'Git set to path failed');
          }
        }

        /// MacOS platform
        else if (Platform.isMacOS) {
          state = state.copyWith(
            progress: Progress.downloading,
          );
          await run('brew install git', verbose: false);
        }

        /// Linux Distros
        else {
          state = state.copyWith(
            progress: Progress.downloading,
          );
          await run('sudo apt-get install git', verbose: false);
        }
      }

      /// Else we need to get version information.
      else if (!SharedPref().pref.containsKey(SPConst.gitPath) ||
          !SharedPref().pref.containsKey(SPConst.gitVersion)) {
        await logger.file(LogTypeTag.info, 'Git found at - $gitPath');
        await SharedPref().pref.setString(SPConst.gitPath, gitPath);

        state = state.copyWith(gitVersion: await getGitBinVersion());

        await logger.file(
            LogTypeTag.info, 'Git version: ${state.gitVersion.toString()}');
        await SharedPref()
            .pref
            .setString(SPConst.gitVersion, state.gitVersion!.toString());

        state = state.copyWith(
          progress: Progress.done,
        );
      } else {
        await logger.file(
            LogTypeTag.info, 'Loading git details from shared preferences');
        gitPath = SharedPref().pref.getString(SPConst.gitPath);
        await logger.file(LogTypeTag.info, 'Git found at - $gitPath');
        await logger.file(
            LogTypeTag.info, 'Git version: ${state.gitVersion.toString()}');
        state = state.copyWith(
          progress: Progress.done,
        );
      }
    } on ShellException catch (shellException, s) {
      state = state.copyWith(
        progress: Progress.failed,
      );
      await logger.file(LogTypeTag.error, shellException.message,
          stackTrace: s);
    } catch (e, s) {
      state = state.copyWith(
        progress: Progress.failed,
      );
      await logger.file(LogTypeTag.error, e.toString(), stackTrace: s);
    }
  }
}
