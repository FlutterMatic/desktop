import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:manager/core/libraries/api.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/ui/info_widget.dart';
import 'package:manager/meta/views/welcome/components/button.dart';
import 'package:manager/meta/views/welcome/components/header_title.dart';

class WelcomeGettingStarted extends StatefulWidget {
  const WelcomeGettingStarted(this.onContinue, {Key? key}) : super(key: key);
  final Function() onContinue;

  @override
  _WelcomeGettingStartedState createState() => _WelcomeGettingStartedState();
}

class _WelcomeGettingStartedState extends State<WelcomeGettingStarted> {
  Future<void> _exponentialBackOff(Function callback,
      [bool haveBackOff = false]) async {
    try {
      if (haveBackOff) {
        await Future<void>.delayed(const Duration(seconds: 5));
      }
      await callback();
    } catch (_) {
      await _exponentialBackOff(callback, true);
    }
  }

  Future<void> _initCalls() async {
    await _exponentialBackOff(() async {
      await context.read<FlutterMaticAPINotifier>().fetchAPIData();
      apiData = context.read<FlutterMaticAPINotifier>().apiMap;
    });
    await _exponentialBackOff(() async {
      await context.read<FlutterSDKNotifier>().fetchSDKData(apiData);
      sdkData = context.read<FlutterSDKNotifier>().sdkMap;
    });
    await _exponentialBackOff(() async {
      await context.read<VSCodeAPINotifier>().fetchVscAPIData();
      tagName = context.read<VSCodeAPINotifier>().tag_name;
      sha = context.read<VSCodeAPINotifier>().sha;
    });
  }

  @override
  void initState() {
    _initCalls();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        welcomeHeaderTitle(
          Assets.flutter,
          Install.flutter,
          InstallContent.welcome,
          iconHeight: 50,
        ),
        const SizedBox(height: 20),
        infoWidget(
            'Please make sure you have a good internet connection for the setup to go as smooth as possible.'),
        const SizedBox(height: 30),
        WelcomeButton('Continue', widget.onContinue),
      ],
    );
  }
}
