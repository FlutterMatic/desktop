import 'package:flutter/material.dart';
import 'package:flutter_installer/utils/constants.dart';

class SquareButton extends StatelessWidget {
  final double size;
  final Widget icon;
  final Function() onPressed;
  final Color? color, hoverColor;
  final String? tooltip;

  SquareButton({
    this.size = 40,
    this.color = kGreyColor,
    this.hoverColor,
    this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: size, maxWidth: size),
        child: tooltip == null
            ? _button(context)
            : Tooltip(message: tooltip!, child: _button(context),),
      );

  Widget _button(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return MaterialButton(
      focusColor: customTheme.focusColor,
      highlightColor: customTheme.highlightColor,
      splashColor: customTheme.splashColor,
      hoverColor: hoverColor ?? customTheme.buttonColor,
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size > 40 ? 10 : 5),
      ),
      color: customTheme.buttonColor,
      elevation: 0,
      hoverElevation: 0,
      focusElevation: 0,
      highlightElevation: 0,
      minWidth: size,
      height: size,
      child: Center(
        child: SizedBox(
          height: size,
          width: size,
          child: icon,
        ),
      ),
    );
  }
}
