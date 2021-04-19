import 'package:flutter/material.dart';
import 'package:flutter_installer/services/checks.dart';
import 'package:flutter_installer/utils/constants.dart';

class StatusCheck extends StatefulWidget {
  const StatusCheck({Key? key}) : super(key: key);

  @override
  _StatusCheckState createState() => _StatusCheckState();
}

class _StatusCheckState extends State<StatusCheck> {
  Future<void> _loadServices() async {
    if (mounted) {
      CheckDependencies checkDependencies = CheckDependencies();
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
    }
    if (mounted) {
      await Navigator.pushReplacementNamed(context, PageRoutes.routeHome);
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
}
