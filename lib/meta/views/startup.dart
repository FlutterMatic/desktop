import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/core/notifiers/change.notifier.dart';
import 'package:manager/core/notifiers/flutter.notifier.dart';
import 'package:manager/core/notifiers/java.notifier.dart';
import 'package:manager/core/notifiers/theme.notifier.dart';
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
  void didChangeDependencies() {
    context.read<MainChecksNotifier>().startChecking(context);
    super.didChangeDependencies();
  }

  SelectableText get _text {
    {
      return SelectableText(
        context.watch<MainChecksNotifier>().value ==
                ApplicationCheckType.FLUTTER_CHECK
            ? context.watch<FlutterChangeNotifier>().value
            : context.watch<JavaChangeNotifier>().value,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      );
    }
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
          child: Stack(
            children: <Widget>[
              Column(
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
                  _text,
                ],
              ),
              const Positioned(
                bottom: 10,
                right: 0,
                left: 0,
                child: Center(
                  child: SelectableText(
                    'Made with 💙',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
