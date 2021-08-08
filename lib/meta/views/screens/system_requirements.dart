import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:manager/meta/views/welcome/components/custom_window.dart';

class SystemRequirementsScreen extends StatefulWidget {
  const SystemRequirementsScreen({Key? key}) : super(key: key);

  @override
  _SystemRequirementsScreenState createState() =>
      _SystemRequirementsScreenState();
}

class _SystemRequirementsScreenState extends State<SystemRequirementsScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomWindow(
      child: Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('System requirements.'),
        ),
      ),
    );
  }
}
