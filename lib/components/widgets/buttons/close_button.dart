import 'package:flutter/material.dart';
import 'package:manager/components/widgets/buttons/square_button.dart';

class CustomCloseButton extends StatelessWidget {
  final Function? onClose;

  CustomCloseButton({this.onClose});

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return SquareButton(
      icon: Icon(Icons.close_rounded,
          color: customTheme.textTheme.bodyText1!.color),
      color: customTheme.buttonColor,
      hoverColor: customTheme.errorColor,
      onPressed: onClose == null
          ? () => Navigator.pop(context)
          : (onClose as Function()?),
    );
  }
}
