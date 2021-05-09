import 'package:flutter/material.dart';

class Spinner extends StatelessWidget {
  final double thickness;

  Spinner({this.thickness = 4});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: thickness,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueGrey),
      ),
    );
  }
}
