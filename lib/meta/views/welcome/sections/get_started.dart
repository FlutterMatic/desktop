// 🎯 Dart imports:
import 'dart:async';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:manager/core/libraries/services.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';
import 'package:retry/retry.dart';

// 🌎 Project imports:
import 'package:manager/core/libraries/api.dart';
import 'package:manager/core/libraries/components.dart';
import 'package:manager/core/libraries/constants.dart';

class WelcomeGettingStarted extends StatefulWidget {
  const WelcomeGettingStarted(this.onContinue, {Key? key}) : super(key: key);
  final Function() onContinue;

  @override
  _WelcomeGettingStartedState createState() => _WelcomeGettingStartedState();
}

class _WelcomeGettingStartedState extends State<WelcomeGettingStarted> {
  final RetryOptions _options = const RetryOptions(maxAttempts: 5);

  int _totalAttempts = 0;

  bool _isLoading = false;

  Future<String> _initCalls() async {
    try {
      String _result = 'success';
      await _options.retry(
        () async {
          if (apiData == null) {
            await context.read<FlutterMaticAPINotifier>().fetchAPIData();
            apiData = context.read<FlutterMaticAPINotifier>().apiMap;
          }
        },
        onRetry: (Exception e) async {
          _totalAttempts++;
          if (_totalAttempts == _options.maxAttempts) {
            await logger.file(LogTypeTag.info,
                'Couldn\'t initialize for setup because of connection issues.');
            _result = 'error';
            return;
          }
        },
        retryIf: (Exception e) => e is SocketException || e is TimeoutException,
      );
      await _options.retry(
        () async {
          if (sdkData == null) {
            await context.read<FlutterSDKNotifier>().fetchSDKData(apiData);
            sdkData = context.read<FlutterSDKNotifier>().sdkMap;
          }
        },
        onRetry: (Exception e) async {
          _totalAttempts++;
          if (_totalAttempts == _options.maxAttempts) {
            await logger.file(LogTypeTag.info,
                'Couldn\'t initialize for setup and attempted to fetch $_totalAttempts times.');
            _result = 'error';
            return;
          }
        },
        retryIf: (Exception e) => e is SocketException || e is TimeoutException,
      );
      await _options.retry(
        () async {
          if (tagName == null || sha == null) {
            await context.read<VSCodeAPINotifier>().fetchVscAPIData();
            tagName = context.read<VSCodeAPINotifier>().tagName;
            sha = context.read<VSCodeAPINotifier>().sha;
          }
        },
        onRetry: (Exception e) async {
          _totalAttempts++;
          if (_totalAttempts == _options.maxAttempts) {
            await logger.file(LogTypeTag.info,
                'Couldn\'t initialize for setup and attempted to fetch $_totalAttempts times.');
            _result = 'error';
            return;
          }
        },
        retryIf: (Exception e) => e is SocketException || e is TimeoutException,
      );

      return _result;
    } catch (_) {
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
              Install.flutter,
              InstallContent.welcome,
              iconHeight: 50,
            ),
            VSeparators.large(),
            if (snapshot.hasData && snapshot.data == 'error')
              informationWidget(
                'Something went wrong. Please check your internet connection and try again.',
                type: InformationType.error,
              )
            else if (snapshot.hasData && snapshot.data == 'success')
              infoWidget(context,
                  'Please make sure you have a good internet connection for the setup to go as smooth as possible.')
            else if (!snapshot.hasData)
              hLoadingIndicator(context: context),
            VSeparators.large(),
            if (snapshot.hasData && snapshot.data == 'error')
              WelcomeButton(
                onInstall: () {},
                buttonText: 'Retry',
                loading: _isLoading,
                onContinue: () async {
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
