import 'package:flutter/material.dart';
import 'package:flutter_installer/screens/home_screen.dart';
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
      flutterInstalled = await checkDependencies.checkFlutter();
      javaInstalled = await checkDependencies.checkJava();
      vscInstalled = await checkDependencies.checkVSC();
      vscInsidersInstalled = await checkDependencies.checkVSCInsiders();
      studioInstalled = await checkDependencies.checkAndroidStudios();
    }
    if (mounted) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
        ),
      ),
    );
  }
}
