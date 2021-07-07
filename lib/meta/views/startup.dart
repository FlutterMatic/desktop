import 'package:bitsdojo_window/bitsdojo_window.dart' show appWindow;
import 'package:flutter/material.dart'
    show
        BuildContext,
        Center,
        CircularProgressIndicator,
        Colors,
        Column,
        DragStartDetails,
        FontWeight,
        GestureDetector,
        HitTestBehavior,
        Key,
        MainAxisAlignment,
        Scaffold,
        SizedBox,
        State,
        StatefulWidget,
        Text,
        TextStyle,
        Widget;
import 'package:manager/core/notifiers/theme.notifier.dart'
    show ThemeChangeNotifier;
import 'package:manager/core/services/checks/flutter.check.dart';
import 'package:provider/provider.dart';

class Startup extends StatefulWidget {
  final ThemeChangeNotifier themeChangeNotifier;
  Startup(
    this.themeChangeNotifier, {
    Key? key,
  }) : super(key: key);

  @override
  _StartupState createState() => _StartupState();
}

class _StartupState extends State<Startup> {
  bool reverse = false;
  int easterEggThemeCount = 0;
  @override
  void initState() {
    Future<bool>.microtask(() => context.read<FlutterCheck>().checkFlutter());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (DragStartDetails details) {
          appWindow.startDragging();
        },
        onTap: () async {
          setState(() {
            reverse = !reverse;
            easterEggThemeCount++;
          });
          if (easterEggThemeCount % 7 == 0) {
            await context.read<ThemeChangeNotifier>().updateTheme(reverse);
            setState(() {
              easterEggThemeCount = 0;
            });
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(
                color: widget.themeChangeNotifier.isDarkTheme
                    ? Colors.lightBlueAccent.withOpacity(0.6)
                    : Colors.lightBlueAccent,
                strokeWidth: 3,
              ),
              const SizedBox(
                height: 30,
              ),
              Consumer<FlutterCheck>(builder:
                  (BuildContext context, FlutterCheck flutterCheck, Widget? _) {
                return Text(
                  flutterCheck.checkStatus,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
