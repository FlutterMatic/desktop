import 'package:flutter/material.dart';
import 'package:flutter_installer/utils/constants.dart';

class RoundButton extends StatelessWidget {
  final double size;
  final Function() onPressed;
  final String tooltip;
  final Widget? icon;

  RoundButton({
    this.size = 40,
    this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: MaterialButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: kGreyColor,
        elevation: 0,
        hoverElevation: 0,
        focusElevation: 0,
        highlightElevation: 0,
        minWidth: size,
        height: size,
        child: SizedBox(
          height: size,
          width: size,
          child: icon ?? const Icon(Icons.settings),
        ),
      ),
    );
  }
}
