import 'package:flutter/material.dart';

class Spinner extends StatelessWidget {
  final double thickness;
  final double size;

  const Spinner({Key? key, this.thickness = 4, this.size = 30}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: thickness,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueGrey),
        ),
      ),
    );
  }
}
