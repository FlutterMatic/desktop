import 'package:flutter/material.dart';
import 'package:manager/core/libraries/components.dart';

class PreLoading extends StatefulWidget {
  const PreLoading({Key? key}) : super(key: key);

  @override
  _PreLoadingState createState() => _PreLoadingState();
}

class _PreLoadingState extends State<PreLoading> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            hLoadingIndicator(
              context: context,
            ),
            const Text('Loading necessary data'),
          ],
        ),
      ),
    );
  }
}
