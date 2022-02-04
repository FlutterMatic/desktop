// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/meta/utils/app_theme.dart';

class RoundContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;
  final double? radius;
  final Color? color;
  final double borderWith;
  final Color? borderColor;
  final EdgeInsets? padding;
  final bool disableInnerRadius;

  const RoundContainer({
    Key? key,
    required this.child,
    this.color,
    this.borderWith = 1,
    this.height,
    this.width,
    this.radius,
    this.borderColor = Colors.transparent,
    this.disableInnerRadius = false,
    this.padding = const EdgeInsets.all(10),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: color ??
            (Theme.of(context).isDarkTheme
                ? Colors.blueGrey.withOpacity(0.2)
                : AppTheme.lightCardColor),
        border: Border.all(color: borderColor!, width: borderWith),
        borderRadius: BorderRadius.circular(radius ?? 5),
      ),
      child: disableInnerRadius
          ? child
          : ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: child,
            ),
    );
  }
}
