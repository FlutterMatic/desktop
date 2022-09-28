// 🎯 Dart imports:
import 'dart:async';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retry/retry.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/enum.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/core/models/api/fluttermatic.dart';
import 'package:fluttermatic/core/notifiers/models/state/api/flutter_sdk.dart';
import 'package:fluttermatic/core/notifiers/models/state/api/fm_api.dart';
import 'package:fluttermatic/core/notifiers/models/state/api/vscode_api.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/space.dart';
import 'package:fluttermatic/core/notifiers/notifiers/api/flutter_sdk.dart';
import 'package:fluttermatic/core/notifiers/notifiers/api/fluttermatic.dart';
import 'package:fluttermatic/core/notifiers/notifiers/api/vscode.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/views/dialogs/drive_error.dart';
import 'package:fluttermatic/meta/views/dialogs/low_drive_storage.dart';
import 'package:fluttermatic/meta/views/setup/components/button.dart';
import 'package:fluttermatic/meta/views/setup/components/header_title.dart';
import 'package:fluttermatic/meta/views/setup/components/loading_indicator.dart';

class SetUpGettingStarted extends ConsumerStatefulWidget {
  final Function() onContinue;
  const SetUpGettingStarted({
    Key? key,
    required this.onContinue,
  }) : super(key: key);

  @override
  _SetUpGettingStartedState createState() => _SetUpGettingStartedState();
}

class _SetUpGettingStartedState extends ConsumerState<SetUpGettingStarted> {
  final RetryOptions _options = const RetryOptions(maxAttempts: 5);

  int _totalAttempts = 0;

  bool _isLoading = false;

  // Notifiers
  late final FlutterMaticAPINotifier fmAPINotifier =
      ref.watch(fmAPIStateNotifier.notifier);

  late final VSCodeAPINotifier vscNotifier =
      ref.watch(vsCodeAPIStateNotifier.notifier);

  late final FlutterSDKNotifier flutterSdkNotifier =
      ref.watch(flutterSdkAPIStateNotifier.notifier);

  // States
  late final FlutterMaticAPIState fmAPIState = ref.watch(fmAPIStateNotifier);

  late final VSCodeAPIState vscState = ref.watch(vsCodeAPIStateNotifier);

  late final FlutterSDKState flutterSdkState =
      ref.watch(flutterSdkAPIStateNotifier);

  late final SpaceState spaceState = ref.watch(spaceStateController);

  Future<String> _initCalls() async {
    try {
      // ignore: unused_local_variable
      String result = 'success';

      await _options.retry(
        () async {
          if (fmAPIState.apiMap == const FlutterMaticAPI(null) && mounted) {
            await fmAPINotifier.fetchAPIData();
            await logger.file(LogTypeTag.info,
                'Fetched FlutterMatic API data: ${fmAPIState.apiMap.data}');
          }
        },
        onRetry: (_) async {
          _totalAttempts++;
          if (_totalAttempts == _options.maxAttempts && mounted) {
            await logger.file(LogTypeTag.info,
                'Couldn\'t initialize for setup because of connection issues.');
            result = 'error';
            return;
          }
        },
        retryIf: (_) => _ is SocketException || _ is TimeoutException,
      );
      await _options.retry(
        () async {
          if (flutterSdkState.sdk.isEmpty && mounted) {
            await flutterSdkNotifier.fetchSDKData();
            await logger.file(LogTypeTag.info,
                'Fetched Flutter SDK data: ${flutterSdkState.sdkMap.data.toString()}');
          }
        },
        onRetry: (_) async {
          _totalAttempts++;
          if (_totalAttempts == _options.maxAttempts && mounted) {
            await logger.file(LogTypeTag.info,
                'Couldn\'t initialize for setup and attempted to fetch $_totalAttempts times.');
            result = 'error';
            return;
          }
        },
        retryIf: (_) => _ is SocketException || _ is TimeoutException,
      );
      await _options.retry(
        () async {
          if ((vscState.tagName.isEmpty || vscState.sha.isEmpty) && mounted) {
            await vscNotifier.fetchVscAPIData();
            await logger.file(LogTypeTag.info,
                'Fetched VSC tag name data: ${vscState.tagName}');
            await logger.file(LogTypeTag.info,
                'Fetched VSC sha data: ${vscState.sha.toString()}');
          }
        },
        onRetry: (_) async {
          _totalAttempts++;
          if (_totalAttempts == _options.maxAttempts && mounted) {
            await logger.file(LogTypeTag.info,
                'Couldn\'t initialize for setup and attempted to fetch $_totalAttempts times.');
            result = 'error';
            return;
          }
        },
        retryIf: (_) => _ is SocketException || _ is TimeoutException,
      );

      // If we have a drive error, we show a dialog error until resolved.
      if (spaceState.hasConflictingError) {
        await showDialog(
          context: context,
          builder: (_) => const SystemDriveErrorDialog(),
        );
      }

      // If we are low in space, show a dialog that won't allow interaction
      // until we have enough space.
      if (spaceState.lowDriveSpace && mounted) {
        await showDialog(
          context: context,
          builder: (_) => const LowDriveSpaceDialog(),
          barrierDismissible: false,
        );
      }

      return result;
    } catch (_, s) {
      await logger.file(LogTypeTag.error,
          'Couldn\'t request to make FlutterMatic API calls initially for setup. $_',
          stackTraces: s);
      return 'error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _initCalls(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return Column(
          children: <Widget>[
            setUpHeaderTitle(
              Assets.flutter,
              'Install Flutter',
              'Welcome to FlutterMatic. You will be guided through the steps necessary to setup and install Flutter on your device.',
              iconHeight: 50,
            ),
            VSeparators.large(),
            if (snapshot.hasData && snapshot.data == 'error')
              informationWidget(
                'Something went wrong. Please check your internet connection and try again.',
                type: InformationType.error,
              )
            else if (snapshot.hasData && snapshot.data == 'success')
              informationWidget(
                'Please make sure you have a good internet connection for the setup to go as smooth as possible.',
                type: InformationType.green,
              )
            else if (!snapshot.hasData)
              hLoadingIndicator(context: context),
            VSeparators.large(),
            if (snapshot.hasData && snapshot.data == 'error')
              SetUpButton(
                onInstall: () {},
                buttonText: allowDevControls ? 'Continue' : 'Retry',
                loading: _isLoading,
                onContinue: allowDevControls
                    ? widget.onContinue
                    : () async {
                        setState(() {
                          _totalAttempts = 0;
                          _isLoading = true;
                        });
                        await _initCalls();
                        setState(() => _isLoading = false);
                      },
                progress: Progress.done,
              )
            else
              SetUpButton(
                onInstall: () {},
                onContinue: widget.onContinue,
                progress:
                    snapshot.hasData ? Progress.done : Progress.downloading,
              ),
          ],
        );
      },
    );
  }
}
