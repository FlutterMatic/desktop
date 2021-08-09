import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:manager/meta/views/welcome/components/windows_controls.dart';

class CustomWindow extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  CustomWindow({
    required this.child,
    this.appBar,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(0, appWindow.titleBarHeight, 0, 0),
            child: child,
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
