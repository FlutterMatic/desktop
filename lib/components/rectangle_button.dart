import 'package:flutter/material.dart';
import 'package:flutter_installer/utils/constants.dart';

class RectangleButton extends StatelessWidget {
  final double height;
  final double width;
  final double radius;
  final Widget child;
  final Color? color;
  final Function() onPressed;

  RectangleButton({
    this.height = 40,
    this.width = 100,
    this.radius = 5,
    this.color = kLightGreyColor,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius),),
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
            padding: const EdgeInsets.all(10),
            child: child,
          ),),
    );
  }
}
