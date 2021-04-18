import 'package:flutter/material.dart';
import 'package:flutter_installer/services/checks.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'package:lottie/lottie.dart';

class CheckStates extends StatefulWidget {
  @override
  _CheckStatesState createState() => _CheckStatesState();
}

class _CheckStatesState extends State<CheckStates> {
  CheckDependencies checkDependencies = CheckDependencies();
  Future<void> statesCheck() async {
    if (mounted) {
      flutterExist = await checkDependencies.checkFlutter();
      javaInstalled = await checkDependencies.checkJava();
      vscInstalled = await checkDependencies.checkVSC();
      vscInsidersInstalled = await checkDependencies.checkVSCInsiders();
      studioInstalled = await checkDependencies.checkAndroidStudios();
    }
    if (mounted) {
      await Navigator.pushReplacementNamed(context, PageRoutes.routeHome);
    }
  }

  @override
  void initState() {
    super.initState();
    statesCheck();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Hero(
                tag: 'logo',
                child: Image.asset(
                  Assets.flutterIcon,
                  height: 0.2 * MediaQuery.of(context).size.height,
                ),
              ),
              Lottie.asset(LottieAssets.searching,
                  height: 0.2 * MediaQuery.of(context).size.height),
              const AnimatedDefaultTextStyle(
                duration: Duration(milliseconds: 300),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                child: Text(
                  'Checking for pre-installed softwares, It may take a while.',
                ),
              ),
            ],
          ),
        ),
      );
}
