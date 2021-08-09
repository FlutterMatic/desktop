import 'package:flutter/material.dart';

class RoundContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;
  final double? radius;
  final Color? color;
  final double borderWith;
  final Color? borderColor;
  final EdgeInsets? padding;

  RoundContainer({
    required this.child,
    this.color,
    this.borderWith = 1,
    this.height,
    this.width,
    this.radius,
    this.borderColor = Colors.transparent,
    this.padding = const EdgeInsets.all(10),
  });

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return Container(
      height: height,
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? customTheme.primaryColorLight,
        border: Border.all(color: borderColor!, width: borderWith),
        borderRadius: BorderRadius.circular(radius ?? 5),
      ),
      child: child,
    );
  }
}
