import 'package:flutter/material.dart';
import 'package:flutter_installer/utils/responsive_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) => ResponsiveLayout(
        child: const Center(
          child: Text('Home'),
        ),
      );
}
