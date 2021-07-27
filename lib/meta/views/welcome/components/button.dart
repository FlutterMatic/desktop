import 'package:flutter/material.dart';

Widget welcomeButton(String title, Function onPressed, {bool disabled = false}) {
  return SizedBox(
    width: 210,
    height: 50,
    child: IgnorePointer(
      ignoring: disabled,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: disabled ? 0.5 : 1,
        child: MaterialButton(
          height: 58,
          minWidth: 270,
          color: const Color(0xffCDD4DD),
          onPressed: onPressed as Function()?,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_rounded, size: 18),
            ],
          ),
        ),
      ),
    ),
  );
}