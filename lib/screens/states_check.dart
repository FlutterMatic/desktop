import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/dialog_header.dart';
import 'package:flutter_installer/components/dialog_templates/general/pref_intro.dart';
import 'package:flutter_installer/components/widgets/dialog_template.dart';
import 'package:flutter_installer/components/widgets/rectangle_button.dart';
import 'package:flutter_installer/screens/home_screen.dart';
import 'package:flutter_installer/services/checks.dart';
import 'package:flutter_installer/services/flutter_actions.dart';
import 'package:flutter_installer/services/themes.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class StatusCheck extends StatefulWidget {
  const StatusCheck({Key? key}) : super(key: key);

  @override
  _StatusCheckState createState() => _StatusCheckState();
}

class _StatusCheckState extends State<StatusCheck> {
  late SharedPreferences _pref;
  Future<void> _loadServices() async {
    _pref = await SharedPreferences.getInstance();
    if (mounted) {
      CheckDependencies checkDependencies = CheckDependencies();
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
        try {
          FlutterActions().checkProjects();
        } catch (_) {
          await showDialog(
            context: context,
            builder: (_) => DialogTemplate(
              child: Column(
                children: [
                  DialogHeader(title: 'No Projects Found'),
                  const SizedBox(height: 20),
                  const Text(
                    'There are no Flutter projects in the path provided. Please try updating the path. If there are Flutter projects, then please create a new issue on GitHub.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  RectangleButton(
                    onPressed: () => Navigator.pop(context),
                    width: double.infinity,
                    child: Text(
                      'OK',
                      style: TextStyle(
                          color: currentTheme.isDarkTheme
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                  const SizedBox(height: 10),
                  RectangleButton(
                    onPressed: () {
                      launch('https://www.github.com/fluttermatic');
                      Navigator.pop(context);
                    },
                    width: double.infinity,
                    child: Text(
                      'Go to GitHub',
                      style: TextStyle(
                          color: currentTheme.isDarkTheme
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
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
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
        ),
      ),
    );
  }
}
