import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:manager/core/libraries/api.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/ui/info_widget.dart';
import 'package:manager/meta/views/welcome/components/button.dart';
import 'package:manager/meta/views/welcome/components/header_title.dart';
import 'package:retry/retry.dart';

class WelcomeGettingStarted extends StatefulWidget {
  const WelcomeGettingStarted(this.onContinue, {Key? key}) : super(key: key);
  final Function() onContinue;

  @override
  _WelcomeGettingStartedState createState() => _WelcomeGettingStartedState();
}

class _WelcomeGettingStartedState extends State<WelcomeGettingStarted> {
  RetryOptions r = const RetryOptions(maxAttempts: 8);

  /// TODO(@ZiyadF296): BIG BUG - This function was being called like 4-5 times IDK why!
  /// This reduces the rate limit.
  Future<bool> _initCalls() async {
    try {
      await r.retry(
        () async {
          if (apiData == null) {
            await context.read<FlutterMaticAPINotifier>().fetchAPIData();
            apiData = context.read<FlutterMaticAPINotifier>().apiMap;
          }
        },
        retryIf: (Exception e) => e is SocketException || e is TimeoutException,
      );
      await r.retry(
        () async {
          if (sdkData == null) {
            await context.read<FlutterSDKNotifier>().fetchSDKData(apiData);
            sdkData = context.read<FlutterSDKNotifier>().sdkMap;
          }
        },
        retryIf: (Exception e) => e is SocketException || e is TimeoutException,
      );
      await r.retry(
        () async {
          if (tagName == null || sha == null) {
            await context.read<VSCodeAPINotifier>().fetchVscAPIData();
            tagName = context.read<VSCodeAPINotifier>().tag_name;
            sha = context.read<VSCodeAPINotifier>().sha;
          }
        },
        retryIf: (Exception e) => e is SocketException || e is TimeoutException,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    /// TODO(@ZiyadF296) : See if you can fix this UI part like this.
    return FutureBuilder<bool>(
        future: _initCalls(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          return Column(
            children: <Widget>[
              welcomeHeaderTitle(
                Assets.flutter,
                Install.flutter,
                InstallContent.welcome,
                iconHeight: 50,
              ),
              const SizedBox(height: 20),
              !snapshot.hasData
                  ? Column(
                      children: const <Widget>[
                        CircularProgressIndicator(),
                        Text('Fetching some initial data...'),
                      ],
                    )
                  : infoWidget(context,
                      'Please make sure you have a good internet connection for the setup to go as smooth as possible.'),
              const SizedBox(height: 30),
              WelcomeButton('Continue', widget.onContinue),
            ],
          );
        });
  }
}
