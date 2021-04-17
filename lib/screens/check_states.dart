import 'package:flutter/material.dart';
import 'package:flutter_installer/screens/home_screen.dart';
import 'package:flutter_installer/services/checks.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'package:lottie/lottie.dart';

class CheckStates extends StatefulWidget {
  @override
  _CheckStatesState createState() => _CheckStatesState();
}

class _CheckStatesState extends State<CheckStates> {
  Future<void> statesCheck() async {
    CheckDependencies checkDependencies = CheckDependencies();
    try {
      await checkDependencies.checkFlutter();
      await checkDependencies.checkJava();
      await checkDependencies.checkVSC();
      await checkDependencies.checkVSCInsiders();
      await checkDependencies.checkAndroidStudios();
      await Navigator.push(
        context,
        MaterialPageRoute<Route<dynamic>>(
          builder: (BuildContext context) => HomeScreen(),
        ),
      );
    } catch (e) {
      await Navigator.push(
        context,
        MaterialPageRoute<Route<dynamic>>(
          builder: (BuildContext context) => HomeScreen(),
        ),
      );
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
    statesCheck();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Hero(
              tag: 'logo',
              child: Image.asset(
                Assets.flutterIcon,
                height: 100,
              ),
            ),
            Lottie.asset('assets/lottie/searching.json', height: 300),
            const AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 300),
              style: TextStyle(
                  fontFamily: 'Inter', fontSize: 15, color: Colors.black54),
              child: Text(
                'Checking for pre-installed softwares. This may take a while.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
