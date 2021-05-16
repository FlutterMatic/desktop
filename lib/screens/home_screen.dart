import 'package:flutter/material.dart';
import 'package:flutter_installer/components/dialog_templates/other/bg_activity.dart';
import 'package:flutter_installer/components/dialog_templates/flutter/run_command.dart';
import 'package:flutter_installer/components/dialog_templates/other/status.dart';
import 'package:flutter_installer/components/dialog_templates/settings/settings.dart';
import 'package:flutter_installer/components/widgets/round_container.dart';
import 'package:flutter_installer/components/widgets/square_button.dart';
import 'package:flutter_installer/screens/elements/projects.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'elements/controls.dart';

class HomeScreen extends StatefulWidget {
  static String id = 'home_page';
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
    super.initState();
    _animateFlutterLogo();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return Scrollbar(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 1300,
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
                              textColor:
                                  customTheme.textTheme.bodyText1!.color!),
                        ),
                        const SizedBox(height: 20),
                        // Installed Components
                        MediaQuery.of(context).size.width > 1100
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  // Controls
                                  Expanded(child: Controls()),
                                  const SizedBox(width: 20),
                                  // Projects
                                  Expanded(child: Projects()),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  // Controls
                                  Controls(),
                                  const SizedBox(height: 30),
                                  // Projects
                                  Projects(),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _bottomLeft(), // Bg activity
            _bottomRight(), // Settings, run, etc
          ],
        ),
      ),
    );
  }

  Widget _bottomLeft() {
    ThemeData customTheme = Theme.of(context);
    return Align(
      alignment: Alignment.bottomLeft,
      child: Stack(
        children: <Widget>[
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
          bgActivities.isNotEmpty
              ? Align(
                  alignment: Alignment.topRight,
                  child: RoundContainer(
                    height: 15,
                    width: 15,
                    color: Colors.blueGrey,
                    radius: 100,
                    padding: EdgeInsets.zero,
                    child: const SizedBox.shrink(),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _bottomRight() {
    ThemeData customTheme = Theme.of(context);
    return Align(
      alignment: Alignment.bottomRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 15, 5, 15),
            child: SquareButton(
              color: customTheme.primaryColorLight,
              icon: Icon(Icons.play_arrow_rounded,
                  color: customTheme.iconTheme.color),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => RunCommandDialog(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 15, 5, 15),
            child: SquareButton(
              color: customTheme.primaryColorLight,
              icon: Icon(Iconsdata.chart, color: customTheme.iconTheme.color),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => StatusDialog(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 15, 15, 15),
            child: SquareButton(
              color: customTheme.primaryColorLight,
              icon: Icon(Icons.settings, color: customTheme.iconTheme.color),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => SettingDialog(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
