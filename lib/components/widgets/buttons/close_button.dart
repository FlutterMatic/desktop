// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';

class CustomCloseButton extends StatelessWidget {
  final VoidCallback? onClose;
  final Color iconColor;
  final Color? onHoverColor;

  const CustomCloseButton(
      {Key? key, this.onClose, this.iconColor = kRedColor, this.onHoverColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SquareButton(
      icon: Icon(
        Icons.close_rounded,
        color: iconColor,
      ),
      color: Colors.transparent,
      hoverColor: onHoverColor ?? AppTheme.errorColor,
      onPressed: onClose ?? () => Navigator.pop(context),
    );
  }
}
