import 'package:flutter/material.dart';
import 'package:flutter_installer/utils/constants.dart';

class RectangleButton extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius? radius;
  final EdgeInsets? padding;
  final Widget child;
  final Color? color;
  final Function? onPressed;

  RectangleButton({
    this.height = 40,
    this.width = 100,
    this.radius,
    this.color = kLightGreyColor,
    this.padding,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed as void Function()?,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: radius ?? BorderRadius.circular(5),
      ),
      color: color,
      elevation: 0,
      hoverElevation: 0,
      focusElevation: 0,
      highlightElevation: 0,
      minWidth: width,
      height: height,
      child: SizedBox(
        height: height,
        width: width,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(10),
          child: Center(child: child),
        ),
      ),
    );
  }
}
