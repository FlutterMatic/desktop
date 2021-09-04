import 'package:flutter/material.dart';
import 'package:manager/core/libraries/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TabViewWidget(
          tabs: <TabViewObject>[
            TabViewObject('Home', Container()),
          ],
        ),
      ),
    );
  }
}
