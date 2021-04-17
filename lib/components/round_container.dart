import 'package:flutter/material.dart';
import 'package:flutter_installer/utils/constants.dart';

class RoundContainer extends StatelessWidget {
  final Widget child;
  final double? radius;
  final Color? color;
  final EdgeInsets? padding;

  RoundContainer({
    required this.child,
    this.radius,
    this.color = kGreyColor,
    this.padding = const EdgeInsets.all(10),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: child,
    );
  }
}
