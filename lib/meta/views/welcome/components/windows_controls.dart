import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

class WindowControls extends StatelessWidget {
  final bool disabled;

  const WindowControls({Key? key, this.disabled = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: disabled ? 0.2 : 1,
      child: IgnorePointer(
        ignoring: disabled,
        child: Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                onPressed: () => appWindow.minimize(),
                splashColor: Colors.transparent,
                splashRadius: 0.01,
                focusColor: Colors.grey,
                hoverColor: Colors.grey,
                highlightColor: Colors.grey,
                color: Colors.grey,
                icon: const Icon(Icons.remove_rounded, size: 15),
              ),
              IconButton(
                onPressed: () => appWindow.maximizeOrRestore(),
                splashColor: Colors.transparent,
                splashRadius: 0.01,
                focusColor: Colors.grey,
                hoverColor: Colors.grey,
                highlightColor: Colors.grey,
                color: Colors.grey,
                icon: const Icon(
                  Icons.crop_square_rounded,
                  size: 15,
                ),
              ),
              IconButton(
                onPressed: () => appWindow.close(),
                splashColor: Colors.transparent,
                splashRadius: 0.01,
                focusColor: Colors.red,
                hoverColor: Colors.red,
                highlightColor: Colors.red,
                color: Colors.red,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 15  ,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
