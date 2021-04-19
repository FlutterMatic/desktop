import 'package:flutter/material.dart';
import 'package:flutter_installer/services/themes.dart';
import 'package:flutter_installer/utils/constants.dart';

class RectangleButton extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius? radius;
  final EdgeInsets? padding;
  final Color? hoverColor;
  final Color? color;
  final bool loading;
  final bool disable;
  final Widget child;
  final Function? onPressed;

  RectangleButton({
    this.height = 40,
    this.width = 100,
    this.disable = false,
    this.radius,
    this.loading = false,
    this.color,
    this.hoverColor,
    this.padding,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return MaterialButton(
      focusColor: customTheme.focusColor,
      highlightColor: customTheme.focusColor,
      splashColor: customTheme.focusColor,
      hoverColor: hoverColor ?? customTheme.focusColor,
      onPressed: disable
          ? null
          : loading
              ? null
              : onPressed as void Function()?,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: radius ?? BorderRadius.circular(5),
      ),
      color: color ??
          (currentTheme.currentTheme == ThemeMode.dark
              ? customTheme.primaryColorLight
              : kLightGreyColor),
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
          child: Center(
              child: loading
                  ? Container(
                      height: 20,
                      width: 20,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                      ),
                    )
                  : child),
        ),
      ),
    );
  }
}
