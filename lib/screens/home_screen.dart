import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/dialogs/bg_activity.dart';
import 'package:flutter_installer/components/dialog_templates/dialogs/settings.dart';
import 'package:flutter_installer/components/widgets/round_container.dart';
import 'package:flutter_installer/components/widgets/square_button.dart';
import 'package:flutter_installer/screens/elements/projects.dart';
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
                  padding: EdgeInsets.fromLTRB(
                      (MediaQuery.of(context).size.width > 500 ? 20 : 10),
                      30,
                      (MediaQuery.of(context).size.width > 500 ? 20 : 10),
                      60),
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
                      MediaQuery.of(context).size.width > 1100
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                //Installed Components
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      installedComponents(context),
                                      controls(context),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 100),
                                //Controls
                                projects(context),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
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
                      onPressed: () => launch(
                          'https://github.com/FlutterMatic/FlutterMatic-desktop'),
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
                          launch('https://twitter.com/FlutterMatic'),
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
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: SquareButton(
                  color: customTheme.primaryColorLight,
                  icon:
                      Icon(Icons.settings, color: customTheme.iconTheme.color),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => ControlSettingsDialog(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
