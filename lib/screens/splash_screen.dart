import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_installer/utils/constants.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Hero(
          tag: 'logo',
          child: Image.asset(
            Assets.flutterIcon,
          ),
        ),
      ),
    );
  }
}
