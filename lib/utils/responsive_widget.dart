import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  ResponsiveLayout({Key? key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => Scaffold(
          body: child,
        ),
      );
}
