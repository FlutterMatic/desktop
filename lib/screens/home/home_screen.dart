import 'package:flutter/material.dart';
import 'components/controls.dart';
import 'components/installed.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

FlutterLogoStyle _flutterLogoStyle = FlutterLogoStyle.markOnly;

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _animateFlutterLogo() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    setState(() => _flutterLogoStyle = FlutterLogoStyle.horizontal);
  }

  @override
  void initState() {
    _animateFlutterLogo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 5),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                  height: 50,
                  child: FlutterLogo(style: _flutterLogoStyle, size: 100)),
              const SizedBox(height: 20),
              // Installed Components
              MediaQuery.of(context).size.width > 1050
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Installed Components
                        installedComponents(),
                        const Spacer(),
                        //Controls
                        controls(),
                      ],
                    )
                  : Column(
                      children: <Widget>[
                        //Installed Components
                        installedComponents(),
                        const SizedBox(height: 30),
                        //Controls
                        controls(),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
