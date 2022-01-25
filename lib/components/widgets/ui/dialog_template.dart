// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/libraries/constants.dart';
import 'package:fluttermatic/core/libraries/utils.dart';
import 'package:fluttermatic/core/libraries/widgets.dart';

class DialogTemplate extends StatelessWidget {
  final Widget child;
  final EdgeInsets? childPadding;
  final bool outerTapExit;
  final Function()? onExit;
  final double? width;
  final double? height;
  final Alignment align;
  final Color? closeBgColor;
  final Color? closeIconColor;
  final bool canScroll;

  const DialogTemplate({
    Key? key,
    required this.child,
    this.childPadding,
    this.width,
    this.height,
    this.align = Alignment.center,
    this.outerTapExit = true,
    this.canScroll = true,
    this.closeBgColor,
    this.closeIconColor,
    this.onExit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onExit ?? (outerTapExit ? () => Navigator.pop(context) : null),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SafeArea(
            child: Container(
              constraints: BoxConstraints(maxWidth: width ?? 500),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Scrollbar(
                isAlwaysShown: false,
                showTrackOnHover: false,
                notificationPredicate: (ScrollNotification notification) =>
                    false,
                child: SingleChildScrollView(
                  physics: canScroll
                      ? const AlwaysScrollableScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  child: GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: RoundContainer(
                        height: height,
                        color: Theme.of(context).isDarkTheme
                            ? AppTheme.darkCardColor
                            : Colors.white,
                        padding: childPadding ?? const EdgeInsets.all(10),
                        child: Center(child: child),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget popUpTextTemplate(String title, String description) {
  return SingleChildScrollView(
    child: Column(
      children: <Widget>[
        //Title
        SelectableText(
          title,
          textAlign: TextAlign.center,
        ),
        VSeparators.normal(),
        //Description
        SelectableText(
          description,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
