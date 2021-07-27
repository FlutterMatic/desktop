import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/meta/utils/app_theme.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Wait till we complete developing...'),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: WindowTitleBarBox(
              child: Row(
                children: <Widget>[
                  Expanded(child: MoveWindow()),
                  const WindowControls()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WindowControls extends StatelessWidget {
  final bool disabled;

  const WindowControls({Key? key, this.disabled = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: disabled ? 0.2 : 1,
      child: IgnorePointer(
        ignoring: disabled,
        child: Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                onPressed: () => appWindow.minimize(),
                splashColor: Colors.transparent,
                splashRadius: 0.01,
                focusColor: Colors.grey,
                hoverColor: Colors.grey,
                highlightColor: Colors.grey,
                color: Colors.black,
                icon: const Icon(Icons.remove_rounded, size: 15),
              ),
              IconButton(
                onPressed: () => appWindow.maximizeOrRestore(),
                splashColor: Colors.transparent,
                splashRadius: 0.01,
                focusColor: Colors.grey,
                hoverColor: Colors.grey,
                highlightColor: Colors.grey,
                color: Colors.black,
                icon: const Icon(
                  Icons.crop_square_rounded,
                  size: 15,
                ),
              ),
              IconButton(
                onPressed: () => appWindow.close(),
                splashColor: Colors.transparent,
                splashRadius: 0.01,
                focusColor: Colors.red,
                hoverColor: Colors.red,
                highlightColor: Colors.red,
                color: Colors.red,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
