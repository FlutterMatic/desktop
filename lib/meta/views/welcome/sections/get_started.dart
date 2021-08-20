import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/core/libraries/api.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/ui/info_widget.dart';
import 'package:manager/core/libraries/components.dart';
import 'package:retry/retry.dart';
import 'dart:io';
import 'dart:async';

class WelcomeGettingStarted extends StatefulWidget {
  const WelcomeGettingStarted(this.onContinue, {Key? key}) : super(key: key);
  final Function() onContinue;

  @override
  _WelcomeGettingStartedState createState() => _WelcomeGettingStartedState();
}

class _WelcomeGettingStartedState extends State<WelcomeGettingStarted> {
  RetryOptions r = const RetryOptions(maxAttempts: 8);

  Future<bool> _initCalls() async {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   snackBarTile(
    //     context,
    //     'Failed start installing example...',
    //     type: SnackBarType.done,
    //     duration: const Duration(minutes: 5),
    //   ),
    // );
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
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
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
            if (!snapshot.hasData)
              hLoadingIndicator(
                context: context,
                message: 'Preparing your system to start installing Flutter',
              )
            else
              infoWidget(context,
                  'Please make sure you have a good internet connection for the setup to go as smooth as possible.'),
            const SizedBox(height: 20),
            WelcomeButton(
              onInstall: () {},
              onContinue: widget.onContinue,
              progress: snapshot.hasData ? Progress.DONE : Progress.DOWNLOADING,
              toolName: 'Getting Started',
            ),
          ],
        );
      },
    );
  }
}
