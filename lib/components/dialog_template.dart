import 'package:flutter/material.dart';
import 'package:flutter_installer/components/round_container.dart';

class DialogTemplate extends StatelessWidget {
  final Widget child;
  final EdgeInsets? childPadding;
  final bool outerTapExit;
  final Alignment align;
  final bool popButtonInclude;
  final Color? closeBgColor;
  final Color? closeIconColor;

  DialogTemplate({
    required this.child,
    this.childPadding,
    this.align = Alignment.center,
    this.outerTapExit = true,
    this.closeBgColor,
    this.closeIconColor,
    this.popButtonInclude = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: outerTapExit ? () => Navigator.pop(context) : null,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: SafeArea(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: SingleChildScrollView(
                  child: GestureDetector(
                    onTap: () {},
                    child: RoundContainer(
                      padding: childPadding ?? const EdgeInsets.all(10),
                      child: Stack(
                        children: [
                          popButtonInclude
                              ? Align(
                                  alignment: Alignment.topRight,
                                  child: CloseButton(color: closeBgColor))
                              : const SizedBox.shrink(),
                          Center(child: child),
                        ],
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

Widget popUpTextTemplate(String title, String description) =>
    SingleChildScrollView(
      child: Column(
        children: [
          //Title
          SelectableText(
            title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          //Description
          SelectableText(
            description,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
