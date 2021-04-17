import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_installer/screens/home_screen.dart';
import 'package:flutter_installer/services/checks.dart';
import 'package:flutter_installer/utils/responsive_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _loadServices() async {
    CheckDependencies checkDependencies = CheckDependencies();
    try {
      setState(() => _message = 'Checking if you have Flutter installed');
      await checkDependencies.checkFlutter();
      setState(() => _message = 'Checking if you have Java installed');
      await checkDependencies.checkJava();
      setState(
          () => _message = 'Checking if you have Visual Studio Code installed');
      await checkDependencies.checkVSC();
      setState(() => _message =
          'Checking if you have Visual Studio Code Insider installed');
      await checkDependencies.checkVSCInsiders();
      setState(
          () => _message = 'Checking if you have Android Studio installed');
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

  Future<void> _loadText() async {
    await Future<void>.delayed(const Duration(seconds: 3), () {
      setState(() => _showText = true);
    });
  }

  bool _showText = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _loadServices();
    _loadText();
  }

  @override
  Widget build(BuildContext context) => ResponsiveLayout(
        child: Center(
          child: Column(
            children: <Widget>[
              const Spacer(),
              const CircularProgressIndicator(),
              const Spacer(),
              _showText
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            color: Colors.black54),
                        child: Text(
                          _message ??
                              'Checking for pre-installed softwares. This may take a while.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : const SizedBox(height: 50),
            ],
          ),
        ),
      );
}
