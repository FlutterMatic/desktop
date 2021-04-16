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
    flutterExist = await checkDependencies.checkFlutter();
    javaInstalled = await checkDependencies.checkJava();
    vscInstalled = await checkDependencies.checkVSC();
    vscInsidersInstalled = await checkDependencies.checkVSCInsiders();
    studioInstalled = await checkDependencies.checkAndroidStudios();
    await Navigator.push(
      context,
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) => HomeScreen(),
      ),
    );
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
              ),
            ),
            Lottie.asset('assets/lottie/searching.json'),
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
}
