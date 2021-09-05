import 'package:flutter/material.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/meta/utils/app_theme.dart';
import 'package:provider/provider.dart';

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
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          leading ?? const SizedBox(width: 40),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (canClose)
            Align(
              alignment: Alignment.centerRight,
              child: CustomCloseButton(
                onClose: onClose,
                iconColor: context.read<ThemeChangeNotifier>().isDarkTheme
                    ? AppTheme.darkTheme.iconTheme.color!
                    : AppTheme.lightTheme.iconTheme.color!,
                onHoverColor: onHoverButtonColor,
              ),
            ),
        ],
      ),
    );
  }
}
