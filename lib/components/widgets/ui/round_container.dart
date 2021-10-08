// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/core/libraries/utils.dart';


class RoundContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;
  final double? radius;
  final Color? color;
  final double borderWith;
  final Color? borderColor;
  final EdgeInsets? padding;

  const RoundContainer({
    Key? key,
    required this.child,
    this.color,
    this.borderWith = 1,
    this.height,
    this.width,
    this.radius,
    this.borderColor = Colors.transparent,
    this.padding = const EdgeInsets.all(10),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? (Theme.of(context).isDarkTheme ? AppTheme.darkCardColor : AppTheme.lightCardColor),
        border: Border.all(color: borderColor!, width: borderWith),
        borderRadius: BorderRadius.circular(radius ?? 5),
      ),
      child: child,
    );
  }
}
