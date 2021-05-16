import 'package:flutter/material.dart';
import 'package:flutter_installer/components/widgets/close_button.dart';

class DialogHeader extends StatelessWidget {
  final String title;
  final bool? canClose;
  final Function()? onClose;
  final Widget? leading;

  DialogHeader({
    required this.title,
    this.canClose = true,
    this.onClose,
    this.leading,
  });

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
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        canClose!
            ? Align(
                alignment: Alignment.centerRight,
                child: CustomCloseButton(onClose: onClose))
            : const SizedBox(width: 40),
      ],
    );
  }
}
