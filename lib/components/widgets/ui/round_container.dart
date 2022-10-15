// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/notifiers/models/state/general/theme.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/meta/utils/general/app_theme.dart';

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
    return Consumer(
      builder: (_, ref, __) {
        ThemeState themeState = ref.watch(themeStateController);

        return Container(
          height: height,
          width: width,
          padding: padding,
          decoration: BoxDecoration(
            color: color ??
                (themeState.darkTheme
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
      },
    );
  }
}
