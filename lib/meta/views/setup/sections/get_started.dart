// 🎯 Dart imports:
import 'dart:async';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';
import 'package:retry/retry.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/app/constants/enum.dart';
import 'package:fluttermatic/components/widgets/ui/warning_widget.dart';
import 'package:fluttermatic/core/api/flutter_sdk.api.dart';
import 'package:fluttermatic/core/api/fluttermatic.api.dart';
import 'package:fluttermatic/core/api/vscode.api.dart';
import 'package:fluttermatic/core/notifiers/space.notifier.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/views/dialogs/drive_error.dart';
import 'package:fluttermatic/meta/views/dialogs/low_drive_storage.dart';
import 'package:fluttermatic/meta/views/setup/components/button.dart';
import 'package:fluttermatic/meta/views/setup/components/header_title.dart';
import 'package:fluttermatic/meta/views/setup/components/loading_indicator.dart';

class SetUpGettingStarted extends StatefulWidget {
  final Function() onContinue;
  const SetUpGettingStarted({
    Key? key,
    required this.onContinue,
  }) : super(key: key);

  @override
  _SetUpGettingStartedState createState() => _SetUpGettingStartedState();
}

class _SetUpGettingStartedState extends State<SetUpGettingStarted> {
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
                'Fetched FlutterMatic API data: ${apiData?.data ?? 'ERROR. NO DATA'}');
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
                'Fetched Flutter SDK data: ${sdkData?.data ?? 'ERROR. NO DATA'}');
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
