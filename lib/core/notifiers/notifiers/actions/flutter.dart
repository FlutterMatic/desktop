// 🎯 Dart imports:
import 'dart:collection';
import 'dart:developer';
import 'dart:io';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
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

  static final List<String> _flutterDoctor = [];

  UnmodifiableListView<String> get flutterDoctor =>
      UnmodifiableListView(_flutterDoctor);

  Future<void> createNewProject(NewFlutterProjectInfo project) async {
    state = state.copyWith(
      loading: true,
      error: '',
      currentActivity: '',
    );

    try {
      if (project.projectPath.isEmpty) {
        state = state.copyWith(
          loading: false,
          error: 'Project path is empty. Please provide a valid path.',
          currentActivity: '',
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

        state = state.copyWith(
          loading: false,
          error: 'At least one platform must be selected.',
          currentActivity: '',
        );

        return;
      }

      // Create the project.
      await shell.cd(project.projectPath).run(
            'flutter create --template=app ${project.projectName} --org ${project.orgName} --platforms $platforms',
          );

      await logger.file(LogTypeTag.info,
          'Created new Flutter project: ${project.toJson()} at path: ${project.projectPath}');

      state = state.copyWith(
        loading: false,
        error: '',
        currentActivity: '',
      );

      return;
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to create new Flutter project: $_',
          stackTraces: s);

      state = state.copyWith(
        loading: false,
        error:
            'Failed to create new Flutter project. Please try again or report this issue.',
        currentActivity: '',
      );

      return;
    }
  }

  Future<void> switchDifferentChannel(String newChannel) async {
    state = state.copyWith(
      loading: true,
      error: '',
      currentActivity: '',
    );

    String oldChannel = read(flutterNotifierController).channel;

    try {
      await shell
          .run('flutter channel $newChannel')
          .asStream()
          .listen((List<ProcessResult> event) {
        if (mounted) {
          state = state.copyWith(
              currentActivity: event.last.stdout.toString().split('\n').first);
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

      state = state.copyWith(
        loading: false,
        error: '',
        currentActivity: '',
      );

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

      state = state.copyWith(
        loading: false,
        error: '',
        currentActivity: '',
      );

      return;
    }
  }

  Future<void> upgradeFlutterVersion() async {
    state = state.copyWith(
      loading: true,
      error: '',
      currentActivity: '',
    );

    try {
      NetworkState connectionNotifier = read(connectionNotifierController);

      // Make sure that there is an internet connection.
      if (!connectionNotifier.connected) {
        state = state.copyWith(
          loading: false,
          error:
              'Seems like you are not connected to the internet. Please double check and try again.',
          currentActivity: '',
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
        state = state.copyWith(
          loading: false,
          error: '',
          currentActivity: '',
        );

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

      state = state.copyWith(
        loading: false,
        error: '',
        currentActivity: '',
      );

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

      state = state.copyWith(
        loading: false,
        error: '',
        currentActivity: '',
      );

      return;
    }
  }

  Future<void> runFlutterDoctor(bool isVerbose) async {
    state = state.copyWith(
      loading: true,
      error: '',
      currentActivity: '',
    );

    try {
      await shell
          .run('flutter doctor${isVerbose ? ' -v' : ''}')
          .asStream()
          .listen((List<ProcessResult> line) {
        if (mounted) {
          _flutterDoctor.addAll(line.last.stdout.toString().split('\n'));

          // Remove all the empty lines
          _flutterDoctor.removeWhere((e) => e.replaceAll(' ', '').isEmpty);

          _flutterDoctor.removeWhere((e) => e.contains('issue found!'));
        }
      }).asFuture();

      await logger.file(LogTypeTag.info,
          'Flutter doctor run ${isVerbose ? 'with' : 'without'} verbose: ${_flutterDoctor..join('\n')}');

      state = state.copyWith(
        loading: false,
        error: '',
        currentActivity: '',
      );

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

      state = state.copyWith(
        loading: false,
        error: '',
        currentActivity: '',
      );

      return;
    }
  }
}
