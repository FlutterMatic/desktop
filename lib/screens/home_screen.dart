import 'package:flutter/material.dart';
import 'package:flutter_installer/components/round_button.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
                height: 50,
                child: FlutterLogo(style: _flutterLogoStyle, size: 100)),
            const SizedBox(height: 50),
            // Installed Components
            Row(
              children: <Widget>[
                _installedComponents(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _installedComponents() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Text(
            'Installed Components',
            style: TextStyle(
                fontSize: 25, color: kDarkColor, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 100),
          RoundButton(
            tooltip: 'Settings',
            onPressed: () {},
          ),
        ],
      ),
    ],
  );
}
