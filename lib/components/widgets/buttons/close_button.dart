import 'package:flutter/material.dart';
import 'package:manager/components/widgets/buttons/square_button.dart';

class CustomCloseButton extends StatelessWidget {
  final VoidCallback? onClose;

  const CustomCloseButton({Key? key, this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return SquareButton(
      icon: Icon(Icons.close_rounded,
          color: customTheme.textTheme.bodyText1!.color),
      color: customTheme.buttonColor,
      hoverColor: customTheme.errorColor,
      onPressed: onClose ?? () => Navigator.pop(context),
    );
  }
}
