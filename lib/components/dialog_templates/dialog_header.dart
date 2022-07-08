// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/components/widgets/buttons/close_button.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/theme.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/meta/utils/general/app_theme.dart';

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
    return Consumer(
      builder: (_, ref, __) {
        ThemeState themeState = ref.watch(themeStateController);

        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  leading ?? const SizedBox(width: 40),
                  const Spacer(),
                  AnimatedOpacity(
                    duration: Duration.zero,
                    opacity: canClose ? 1 : 0,
                    child: IgnorePointer(
                      ignoring: !canClose,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: CustomCloseButton(
                          onClose: onClose,
                          iconColor: themeState.isDarkTheme
                              ? AppTheme.darkTheme.iconTheme.color!
                              : AppTheme.lightTheme.iconTheme.color!,
                          onHoverColor: onHoverButtonColor,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
