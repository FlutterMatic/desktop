import 'package:flutter/material.dart';
import 'package:manager/meta/utils/app_theme.dart';

class WelcomeButton extends StatefulWidget {
  const WelcomeButton(
    this.title,
    this.onPressed, {
    this.disabled = false,
    Key? key,
  }) : super(key: key);
  final String title;
  final Function()? onPressed;
  final bool disabled;

  @override
  _WelcomeButtonState createState() => _WelcomeButtonState();
}

class _WelcomeButtonState extends State<WelcomeButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      height: 50,
      child: IgnorePointer(
        ignoring: widget.disabled,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: widget.disabled ? 0.5 : 1,
          child: MaterialButton(
            height: 58,
            minWidth: 270,
            color: AppTheme.lightTheme.buttonColor,
            onPressed: widget.onPressed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
