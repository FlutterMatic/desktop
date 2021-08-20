import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/meta/utils/app_theme.dart';
import 'package:manager/core/libraries/widgets.dart';

class CustomCloseButton extends StatelessWidget {
  final VoidCallback? onClose;
  final Color? iconColor;
  final Color? onHoverColor;

  const CustomCloseButton(
      {Key? key, this.onClose, this.iconColor, this.onHoverColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SquareButton(
      icon: Icon(
        Icons.close_rounded,
        color: iconColor ?? kRedColor,
      ),
      color: Colors.transparent,
      hoverColor: onHoverColor ?? AppTheme.errorColor,
      onPressed: onClose ?? () => Navigator.pop(context),
    );
  }
}
