import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_template.dart';
import 'package:flutter_installer/components/rectangle_button.dart';
import 'package:flutter_installer/components/square_button.dart';
import 'package:flutter_installer/screens/home/components/projects.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
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
    return Scrollbar(
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 50,
                        child: FlutterLogo(style: _flutterLogoStyle, size: 100),
                      ),
                      const SizedBox(height: 20),
                      // Installed Components
                      MediaQuery.of(context).size.width > 1070
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                //Installed Components
                                Expanded(child: installedComponents()),
                                const SizedBox(width: 150),
                                //Controls
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    controls(context),
                                    const SizedBox(height: 20),
                                    projects(),
                                  ],
                                ),
                              ],
                            )
                          : Column(
                              children: <Widget>[
                                //Installed Components
                                installedComponents(),
                                const SizedBox(height: 30),
                                //Controls
                                controls(context),
                                const SizedBox(height: 30),
                                projects(),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ),
            //Footer
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    SquareButton(
                      padding: const EdgeInsets.all(10),
                      icon: SvgPicture.asset(Assets.gitHub),
                      tooltip: 'GitHub',
                      onPressed: () => launch('https://www.github.com'),
                    ),
                    const SizedBox(width: 5),
                    SquareButton(
                      padding: const EdgeInsets.all(10),
                      icon: SvgPicture.asset(Assets.twitter),
                      tooltip: 'Twitter',
                      onPressed: () => launch('https://www.twitter.com'),
                    ),
                    const SizedBox(width: 5),
                    SquareButton(
                      padding: const EdgeInsets.all(10),
                      icon: SvgPicture.asset(Assets.dartPad),
                      tooltip: 'DartPad',
                      onPressed: () => launch('https://www.dartpad.dev/'),
                    ),
                    const SizedBox(width: 5),
                    SquareButton(
                      padding: const EdgeInsets.all(10),
                      icon: SvgPicture.asset(Assets.docs),
                      tooltip: 'Docs',
                      onPressed: () => launch('https://flutter.dev/docs'),
                    ),
                    const SizedBox(width: 5),
                    SquareButton(
                      padding: const EdgeInsets.all(5),
                      icon: const Icon(Icons.info_outline_rounded),
                      tooltip: 'Credits',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
