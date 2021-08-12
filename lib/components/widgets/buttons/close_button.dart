import 'package:flutter/material.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:provider/provider.dart';
import 'package:manager/meta/utils/app_theme.dart';
import 'package:manager/components/widgets/buttons/square_button.dart';

class CustomCloseButton extends StatelessWidget {
  final VoidCallback? onClose;

  const CustomCloseButton({Key? key, this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SquareButton(
      icon: Icon(Icons.close_rounded,
          color: context.read<ThemeChangeNotifier>().isDarkTheme
              ? Colors.white
              : Colors.black),
      color: Colors.transparent,
      hoverColor: AppTheme.errorColor,
      onPressed: onClose ?? () => Navigator.pop(context),
    );
  }
}
