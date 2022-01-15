// 🐦 Flutter imports:
import 'package:flutter/material.dart';

class Spinner extends StatelessWidget {
  final double size;
  final Color? color;
  final double thickness;

  const Spinner({Key? key, this.color, this.thickness = 3, this.size = 30})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: thickness,
          valueColor: AlwaysStoppedAnimation<Color>(color ?? Colors.blueGrey),
        ),
      ),
    );
  }
}
