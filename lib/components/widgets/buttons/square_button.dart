import 'package:flutter/material.dart';
import 'package:manager/components/widgets/ui/spinner.dart';

class SquareButton extends StatelessWidget {
  final double size;
  final Widget icon;
  final Function()? onPressed;
  final Color? color, hoverColor;
  final bool loading;
  final String? tooltip;

  const SquareButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.size = 40,
    this.color = Colors.grey,
    this.hoverColor,
    this.tooltip,
    this.loading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: size, maxWidth: size),
        child: tooltip == null
            ? _button(context)
            : Tooltip(
                message: tooltip!,
                child: _button(context),
              ),
      );

  Widget _button(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return MaterialButton(
      focusColor: customTheme.focusColor,
      highlightColor: customTheme.highlightColor,
      splashColor: customTheme.splashColor,
      hoverColor: hoverColor ?? customTheme.buttonColor,
      onPressed: loading ? null : onPressed,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size > 40 ? 10 : 5),
      ),
      color: color ?? customTheme.buttonColor,
      elevation: 0,
      hoverElevation: 0,
      focusElevation: 0,
      highlightElevation: 0,
      minWidth: size,
      height: size,
      child: Center(
        child: loading
            ? Spinner(size: 20, thickness: 3)
            : SizedBox(
                height: size,
                width: size,
                child: icon,
              ),
      ),
    );
  }
}
