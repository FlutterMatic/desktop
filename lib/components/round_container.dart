import 'package:flutter/material.dart';
import 'package:flutter_installer/utils/constants.dart';

class RoundContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;
  final double? radius;
  final Color? borderColor;
  final Color? color;
  final EdgeInsets? padding;

  RoundContainer({
    required this.child,
    this.height,
    this.width,
    this.radius,
    this.borderColor = Colors.transparent,
    this.color = kGreyColor,
    this.padding = const EdgeInsets.all(10),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor!, width: 1),
        borderRadius: BorderRadius.circular(radius ?? 10),
      ),
      child: child,
    );
  }
}
