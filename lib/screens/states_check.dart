import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/other/pref_intro.dart';
import 'package:flutter_installer/components/widgets/ui/spinner.dart';
import 'package:flutter_installer/screens/home_screen.dart';
import 'package:flutter_installer/services/checks/win32Checks.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatusCheck extends StatefulWidget {
  static String id = 'status_check';

  @override
  _StatusCheckState createState() => _StatusCheckState();
}

class _StatusCheckState extends State<StatusCheck> {
  late SharedPreferences _pref;
  Future<void> _loadServices() async {
    _pref = await SharedPreferences.getInstance();
    if (mounted) {
      Win32Checks checkDependencies = Win32Checks();
      if (!_pref.containsKey('projects_path')) {
        await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) => PrefIntroDialog(),
        );
      } else {
        projDir = _pref.getString('projects_path');
        flutterInstalled = await checkDependencies.checkFlutter();
        javaInstalled = await checkDependencies.checkJava();
        vscInstalled = await checkDependencies.checkVSC();
        vscInsidersInstalled = await checkDependencies.checkVSCInsiders();
        studioInstalled = await checkDependencies.checkAndroidStudios();
        // emulatorInstalled = await checkDependencies.checkEmulator();
      }
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
    return Scaffold(body: Center(child: Spinner(size: 40, thickness: 3)));
  }
}
