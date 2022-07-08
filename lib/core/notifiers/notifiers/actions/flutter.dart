// 🌎 Project imports:
import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/shared_pref.dart';
import 'package:fluttermatic/core/notifiers/models/payloads/actions/flutter.dart';
import 'package:fluttermatic/core/notifiers/models/payloads/general/notifications.dart';
import 'package:fluttermatic/core/notifiers/models/state/actions/flutter.dart';
import 'package:fluttermatic/core/notifiers/models/state/checks/flutter.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/connection.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/general/shared_pref.dart';

class FlutterActionsNotifier extends StateNotifier<FlutterActionsState> {
  final Reader read;

  FlutterActionsNotifier(this.read) : super(FlutterActionsState.initial());

  void _reset() => state = FlutterActionsState.initial();

  Future<void> createNewProject(NewFlutterProjectInfo project) async {
    state = state.copyWith(
      isLoading: true,
    );

    try {
      if (project.projectPath.isEmpty) {
        _reset();

        state = state.copyWith(
          error: 'Project path is empty. Please provide a valid path.',
        );

        return;
      }

      String platforms = <String>[
        if (project.android) 'android',
        if (project.iOS) 'ios',
        if (project.web) 'web',
        if (project.macos) 'macos',
        if (project.windows) 'windows',
        if (project.linux) 'linux',
      ].join(',');

      // Make sure that [_platforms] is not empty (meaning there is at least
      // one platform selected).
      if (platforms.isEmpty) {
        await logger.file(LogTypeTag.warning,
            'Selected no platform(s) but tried to create a project.');

        _reset();

        state = state.copyWith(
          error: 'At least one platform must be selected.',
        );

        return;
      }

      // Create the project.
      await shell.cd(project.projectPath).run(
            'flutter create --template=app ${project.projectName} --org ${project.orgName} --platforms $platforms',
          );

      await logger.file(LogTypeTag.info,
          'Created new Flutter project: ${project.toJson()} at path: ${project.projectPath}');

      _reset();

      return;
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to create new Flutter project: $_',
          stackTraces: s);

      _reset();

      state = state.copyWith(
        error:
            'Failed to create new Flutter project. Please try again or report this issue.',
      );

      return;
    }
  }

  Future<void> switchDifferentChannel(String newChannel) async {
    state = state.copyWith(
      isLoading: true,
    );

    String oldChannel = read(flutterNotifierController).channel;

    try {
      await shell
          .run('flutter channel $newChannel')
          .asStream()
          .listen((List<ProcessResult> event) {
        if (mounted) {
          state = state.copyWith(
              currentProcess: event.last.stdout.toString().split('\n').first);
        }
      }).asFuture();
      
      await read(flutterNotifierController.notifier).checkFlutter();

      await read(notificationStateController.notifier).newNotification(
        NotificationObject(
          Timeline.now.toString(),
          title: 'Flutter channel switched',
          message:
              'Your Flutter channel was successfully switched to $newChannel from $oldChannel',
          onPressed: null,
        ),
      );

      _reset();

      return;
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Error switching channels: $_',
          stackTraces: s);

      await read(notificationStateController.notifier).newNotification(
        NotificationObject(
          Timeline.now.toString(),
          title: 'Failed to switch Flutter channels',
          message:
              'Failed to switch from $oldChannel to $newChannel. Please try again.',
          onPressed: null,
        ),
      );

      _reset();

      return;
    }
  }

  Future<void> upgradeFlutterVersion() async {
    state = state.copyWith(
      isLoading: true,
    );

    try {
      NetworkState connectionNotifier = read(connectionNotifierController);

      // Make sure that there is an internet connection.
      if (!connectionNotifier.isConnected) {
        _reset();

        state = state.copyWith(
          error:
              'Seems like you are not connected to the internet. Please double check and try again.',
        );
        return;
      }

      // Already Updated Sample Response:
      // Flutter is already up to date on channel stable
      // Flutter 2.8.1 • channel stable • https://github.com/flutter/flutter.git
      // Framework • revision 77d935af4d (6 weeks ago) • 2021-12-16 08:37:33 -0800
      // Engine • revision 890a5fca2e
      // Tools • Dart 2.15.1

      await SharedPref().pref.setString(
          SPConst.lastFlutterUpdateCheck, DateTime.now().toIso8601String());

      await SharedPref().pref.setString(
          SPConst.lastDartUpdateCheck, DateTime.now().toIso8601String());

      List<ProcessResult> result = await shell
          .run('flutter upgrade')
          .onError((Object? _, StackTrace s) async {
        await logger.file(LogTypeTag.error, 'Error while updating Flutter: $_',
            stackTraces: s);

        await read(notificationStateController.notifier).newNotification(
          NotificationObject(
            Timeline.now.toString(),
            title: 'Failed to Upgrade Flutter',
            message:
                'Failed to upgrade Flutter. Please make sure you have a stable network connection and try again.',
            onPressed: null,
          ),
        );

        return [];
      });

      if (result.isEmpty) {
        _reset();

        return;
      }

      FlutterState flutterState = read(flutterNotifierController);

      bool hasNew = !result.join().toLowerCase().contains('flutter is already');

      if (hasNew) {
        await read(notificationStateController.notifier).newNotification(
          NotificationObject(
            Timeline.now.toString(),
            title: 'Latest Flutter Version',
            message:
                'Flutter has been updated to ${flutterState.flutterVersion ?? 'UNKNOWN'} on channel ${flutterState.channel}.',
            onPressed: null,
          ),
        );

        await SharedPref().pref.setString(
            SPConst.lastFlutterUpdate, DateTime.now().toIso8601String());

        await SharedPref().pref.setString(
            SPConst.lastDartUpdate, DateTime.now().toIso8601String());

        await logger.file(LogTypeTag.info,
            'Flutter has been updated to ${flutterState.flutterVersion} on channel ${flutterState.channel}.');
      } else {
        await logger.file(LogTypeTag.info,
            'Flutter is already up to date on channel stable with version ${flutterState.flutterVersion}. Attempted upgrade when no new version available.');

        await read(notificationStateController.notifier).newNotification(
          NotificationObject(
            Timeline.now.toString(),
            title: 'Latest Flutter Version',
            message:
                'You are already on the latest version on ${flutterState.channel}.',
            onPressed: null,
          ),
        );
      }

      _reset();

      return;
    } catch (_) {
      await logger.file(LogTypeTag.error, 'Error while updating Flutter: $_');

      await read(notificationStateController.notifier).newNotification(
        NotificationObject(
          Timeline.now.toString(),
          title: 'Couldn\'t upgrade your Flutter version',
          message:
              'Something went wrong while upgrading your Flutter version. Please try again.',
          onPressed: null,
        ),
      );

      _reset();

      return;
    }
  }

  Future<void> runFlutterDoctor(bool isVerbose) async {
    state = state.copyWith(
      isLoading: true,
    );

    try {
      await shell
          .run('flutter doctor${isVerbose ? ' -v' : ''}')
          .asStream()
          .listen((List<ProcessResult> line) {
        if (mounted) {
          state.addFlutterDoctor(line.last.stdout.toString().split('\n'));

          // Remove all the empty lines
          state.removeWhereFlutterDoctor(
              (String e) => e.replaceAll(' ', '').isEmpty);

          state.removeWhereFlutterDoctor((String e) {
            return e.contains('issue found!');
          });
        }
      }).asFuture();

      await logger.file(LogTypeTag.info,
          'Flutter doctor run ${isVerbose ? 'with' : 'without'} verbose: ${state.flutterDoctor.join('\n')}');

      _reset();

      return;
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Flutter Doctor failed to run: $_',
          stackTraces: s);

      await read(notificationStateController.notifier).newNotification(
        NotificationObject(
          Timeline.now.toString(),
          title: 'Couldn\'t run Flutter Doctor',
          message: 'Failed to run Flutter doctor. Please try again.',
          onPressed: null,
        ),
      );

      _reset();

      return;
    }
  }
}
