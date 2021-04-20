import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/general/bg_activity.dart';
import 'package:flutter_installer/components/widgets/round_container.dart';
import 'package:flutter_installer/components/widgets/square_button.dart';
import 'package:flutter_installer/screens/elements/projects.dart';
import 'package:flutter_installer/services/themes.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'elements/controls.dart';
import 'elements/installed.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

FlutterLogoStyle _flutterLogoStyle = FlutterLogoStyle.markOnly;

class _HomeScreenState extends State<HomeScreen> {
  bool dark = false;
  Future<void> _animateFlutterLogo() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    setState(() => _flutterLogoStyle = FlutterLogoStyle.horizontal);
  }

  @override
  void initState() {
    _animateFlutterLogo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
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
                        child: FlutterLogo(
                            style: _flutterLogoStyle,
                            size: 100,
                            textColor: customTheme.textTheme.bodyText1!.color!),
                      ),
                      const SizedBox(height: 20),
                      // Installed Components
                      MediaQuery.of(context).size.width > 1070
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                //Installed Components
                                Expanded(
                                  child: installedComponents(context),
                                ),
                                const SizedBox(width: 150),
                                //Controls
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    controls(context),
                                    const SizedBox(height: 20),
                                    projects(context),
                                  ],
                                ),
                              ],
                            )
                          : Column(
                              children: <Widget>[
                                //Installed Components
                                installedComponents(context),
                                const SizedBox(height: 30),
                                //Controls
                                controls(context),
                                const SizedBox(height: 30),
                                projects(context),
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
                      color: customTheme.primaryColorLight,
                      icon: Icon(
                        Iconsdata.github,
                        color: customTheme.iconTheme.color,
                      ),
                      tooltip: 'GitHub',
                      onPressed: () => launch('https://www.github.com/flutter'),
                    ),
                    const SizedBox(width: 5),
                    SquareButton(
                      color: customTheme.primaryColorLight,
                      icon: Icon(
                        Iconsdata.twitter,
                        color: customTheme.iconTheme.color,
                      ),
                      tooltip: 'Twitter',
                      onPressed: () =>
                          launch('https://www.twitter.com/flutterdev'),
                    ),
                    const SizedBox(width: 5),
                    SquareButton(
                      color: customTheme.primaryColorLight,
                      icon: Icon(
                        Iconsdata.dartpad,
                        color: customTheme.iconTheme.color,
                      ),
                      tooltip: 'DartPad',
                      onPressed: () => launch('https://www.dartpad.dev/'),
                    ),
                    const SizedBox(width: 5),
                    SquareButton(
                      color: customTheme.primaryColorLight,
                      icon: Icon(
                        Iconsdata.docs,
                        color: customTheme.iconTheme.color,
                      ),
                      tooltip: 'Docs',
                      onPressed: () => launch('https://flutter.dev/docs'),
                    ),
                    const SizedBox(width: 5),
                    SquareButton(
                      color: customTheme.primaryColorLight,
                      icon: Icon(
                        Iconsdata.info,
                        color: customTheme.iconTheme.color,
                      ),
                      tooltip: 'About',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: IconButton(
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: Icon(currentTheme.isDarkTheme
                      ? Iconsdata.moon
                      : Iconsdata.sun),
                  onPressed: () => currentTheme.toggleTheme(),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: SquareButton(
                      color: customTheme.primaryColorLight,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => BgActivityDialog(),
                        );
                      },
                      icon: Icon(
                        Icons.sync_alt_rounded,
                        color: customTheme.textTheme.bodyText1!.color,
                      ),
                    ),
                  ),
                  bgActivities.isEmpty
                      ? const SizedBox.shrink()
                      : Positioned(
                          right: 0,
                          top: 0,
                          child: RoundContainer(
                            height: 15,
                            width: 15,
                            color: Colors.blueGrey,
                            padding: EdgeInsets.zero,
                            child: const SizedBox.shrink(),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
