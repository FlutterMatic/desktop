import 'package:flutter/material.dart';
import 'package:flutter_installer/screens/check_states.dart';
import 'package:flutter_installer/screens/home_screen.dart';
import 'package:flutter_installer/screens/splash_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Installer',
      home: CheckStates(),
    );
  }
}
