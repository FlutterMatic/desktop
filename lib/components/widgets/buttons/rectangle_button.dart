// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/core/libraries/widgets.dart';

class RectangleButton extends StatelessWidget {
  final double height, width;

  final BorderRadius? radius;

  final EdgeInsets? padding;

  final Color? hoverColor,
      splashColor,
      highlightColor,
      focusColor,
      disableColor,
      contentColor,
      color;

  final bool loading, disable;

  final Widget child;

  final VoidCallback? onPressed;

  const RectangleButton({
    Key? key,
    this.height = 40,
    this.width = 200,
    this.disable = false,
    this.disableColor,
    this.contentColor,
    this.radius,
    this.loading = false,
    this.color,
    this.hoverColor,
    this.splashColor,
    this.focusColor,
    this.highlightColor,
    this.padding,
    required this.child,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      focusColor: focusColor,
      highlightColor: highlightColor,
      splashColor: splashColor,
      hoverColor: hoverColor,
      onPressed: (disable || loading) ? null : onPressed,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: radius ?? BorderRadius.circular(5),
      ),
      color: color ?? Colors.blueGrey.withOpacity(0.2),
      disabledColor: disableColor,
      elevation: 0,
      disabledElevation: 0,
      hoverElevation: 0,
      focusElevation: 0,
      highlightElevation: 0,
      minWidth: width,
      height: height,
      child: SizedBox(
        height: height,
        width: width,
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: loading
                ? const SizedBox(
                    height: 15, width: 15, child: Spinner(thickness: 2))
                : child,
          ),
        ),
      ),
    );
  }
}
