// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/core/libraries/widgets.dart';

class SquareButton extends StatelessWidget {
  final double size;
  final Widget icon;
  final VoidCallback? onPressed;
  final Color? color, hoverColor;
  final bool loading;
  final String? tooltip;

  const SquareButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.size = 40,
    this.color,
    this.hoverColor,
    this.tooltip,
    this.loading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: tooltip,
      child: MergeSemantics(
        child: Tooltip(
          message: tooltip ?? '',
          waitDuration: const Duration(seconds: 1),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: size, maxWidth: size),
            child: MaterialButton(
              focusColor: null,
              highlightColor: null,
              splashColor: null,
              hoverColor: hoverColor,
              onPressed: loading ? null : onPressed,
              padding: EdgeInsets.zero,
              color: color ?? Colors.blueGrey.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size > 40 ? 10 : 5),
              ),
              elevation: 0,
              hoverElevation: 0,
              focusElevation: 0,
              highlightElevation: 0,
              minWidth: size,
              height: size,
              child: Center(
                child: loading
                    ? const Spinner(size: 20, thickness: 3)
                    : SizedBox(height: size, width: size, child: icon),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
