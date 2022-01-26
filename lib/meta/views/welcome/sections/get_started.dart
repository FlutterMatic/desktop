// 🎯 Dart imports:
import 'dart:async';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';
import 'package:retry/retry.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/libraries/api.dart';
import 'package:fluttermatic/core/libraries/components.dart';
import 'package:fluttermatic/core/libraries/constants.dart';
import 'package:fluttermatic/core/libraries/notifiers.dart';
import 'package:fluttermatic/core/libraries/services.dart';
import 'package:fluttermatic/meta/views/dialogs/drive_error.dart';
import 'package:fluttermatic/meta/views/dialogs/low_drive_storage.dart';

class WelcomeGettingStarted extends StatefulWidget {
  final Function() onContinue;
  const WelcomeGettingStarted({
    Key? key,
    required this.onContinue,
  }) : super(key: key);

  @override
  _WelcomeGettingStartedState createState() => _WelcomeGettingStartedState();
}

class _WelcomeGettingStartedState extends State<WelcomeGettingStarted> {
  final RetryOptions _options = const RetryOptions(maxAttempts: 5);

  int _totalAttempts = 0;

  bool _isLoading = false;

  Future<String> _initCalls() async {
    try {
      // ignore: unused_local_variable
      String _result = 'success';
      await _options.retry(
        () async {
          if (apiData == null && mounted) {
            await context.read<FlutterMaticAPINotifier>().fetchAPIData();
            apiData = context.read<FlutterMaticAPINotifier>().apiMap;
            await logger.file(LogTypeTag.info,
                'Fetched FlutterMatic API data: ${apiData?.data}');
          }
        },
        onRetry: (_) async {
          _totalAttempts++;
          if (_totalAttempts == _options.maxAttempts && mounted) {
            await logger.file(LogTypeTag.info,
                'Couldn\'t initialize for setup because of connection issues.');
            _result = 'error';
            return;
          }
        },
        retryIf: (_) => _ is SocketException || _ is TimeoutException,
      );
      await _options.retry(
        () async {
          if (sdkData == null && mounted) {
            await context.read<FlutterSDKNotifier>().fetchSDKData(apiData);
            sdkData = context.read<FlutterSDKNotifier>().sdkMap;
            await logger.file(LogTypeTag.info,
                'Fetched Flutter SDK data: ${sdkData?.data}');
          }
        },
        onRetry: (_) async {
          _totalAttempts++;
          if (_totalAttempts == _options.maxAttempts && mounted) {
            await logger.file(LogTypeTag.info,
                'Couldn\'t initialize for setup and attempted to fetch $_totalAttempts times.');
            _result = 'error';
            return;
          }
        },
        retryIf: (_) => _ is SocketException || _ is TimeoutException,
      );
      await _options.retry(
        () async {
          if (tagName == null || sha == null && mounted) {
            await context.read<VSCodeAPINotifier>().fetchVscAPIData();
            tagName = context.read<VSCodeAPINotifier>().tagName;
            sha = context.read<VSCodeAPINotifier>().sha;
            await logger.file(LogTypeTag.info,
                'Fetched VSC tag name data: ${tagName.toString()}');
            await logger.file(
                LogTypeTag.info, 'Fetched VSC sha data: ${sha.toString()}');
          }
        },
        onRetry: (_) async {
          _totalAttempts++;
          if (_totalAttempts == _options.maxAttempts && mounted) {
            await logger.file(LogTypeTag.info,
                'Couldn\'t initialize for setup and attempted to fetch $_totalAttempts times.');
            _result = 'error';
            return;
          }
        },
        retryIf: (_) => _ is SocketException || _ is TimeoutException,
      );

      // If we have a drive error, we show a dialog error until resolved.
      if (context.read<SpaceCheck>().hasConflictingError) {
        await showDialog(
          context: context,
          builder: (_) => const SystemDriveErrorDialog(),
        );
      }

      // If we are low in space, show a dialog that won't allow interaction
      // until we have enough space.
      if (context.read<SpaceCheck>().lowDriveSpace && mounted) {
        await showDialog(
          context: context,
          builder: (_) => const LowDriveSpaceDialog(),
          barrierDismissible: false,
        );
      }

      return _result;
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
            welcomeHeaderTitle(
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
              WelcomeButton(
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
              WelcomeButton(
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
