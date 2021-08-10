import 'package:flutter/material.dart';
import 'package:manager/components/widgets/buttons/close_button.dart';

class DialogHeader extends StatelessWidget {
  final String title;
  final bool canClose;
  final VoidCallback? onClose;
  final Widget? leading;

  const DialogHeader({
    Key? key,
    required this.title,
    this.canClose = true,
    this.onClose,
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
            child: Text(title, style: const TextStyle(fontSize: 20)),
          ),
        ),
        if (canClose)
          Align(
            alignment: Alignment.centerRight,
            child: CustomCloseButton(onClose: onClose),
          ),
      ],
    );
  }
}
