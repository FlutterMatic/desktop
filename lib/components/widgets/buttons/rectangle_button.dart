// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/components/widgets/ui/spinner.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/theme.dart';
import 'package:fluttermatic/core/notifiers/out.dart';

class RectangleButton extends StatelessWidget {
  final double height, width;

  final BorderRadius? radius;

  final EdgeInsets? padding;

  final Color? hoverColor;
  final Color? splashColor;
  final Color? highlightColor;
  final Color? focusColor;
  final Color? disableColor;
  final Color? contentColor;
  final Color? color;

  final bool loading;
  final bool disable;

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
    return Consumer(
      builder: (_, ref, __) {
        ThemeState themeState = ref.watch(themeStateController);

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
          color: color ??
              Colors.blueGrey.withOpacity(themeState.darkTheme ? 0.2 : 0.1),
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
      },
    );
  }
}
