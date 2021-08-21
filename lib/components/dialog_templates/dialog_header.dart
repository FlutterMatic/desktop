import 'package:flutter/material.dart';
import 'package:manager/core/libraries/widgets.dart';

class DialogHeader extends StatelessWidget {
  final String title;
  final bool canClose;
  final VoidCallback? onClose;
  final Widget? leading;
  final Color? closeIconColor;
  final Color? onHoverButtonColor;

  const DialogHeader({
    Key? key,
    required this.title,
    this.canClose = true,
    this.onClose,
    this.closeIconColor,
    this.onHoverButtonColor,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        leading ?? const SizedBox(width: 40),
        Expanded(
          child: Center(
            child: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        if (canClose)
          Align(
            alignment: Alignment.centerRight,
            child: CustomCloseButton(
              onClose: onClose,
              iconColor: closeIconColor,
              onHoverColor: onHoverButtonColor,
            ),
          ),
      ],
    );
  }
}
