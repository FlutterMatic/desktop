import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

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
                splashRadius: 12,
                focusColor: Colors.black12,
                hoverColor: Colors.black12,
                highlightColor: Colors.black12,
                color: Colors.grey,
                icon: const Icon(Icons.remove_rounded, size: 15),
              ),
              IconButton(
                onPressed: () => appWindow.maximizeOrRestore(),
                splashColor: Colors.transparent,
                splashRadius: 12,
                focusColor: Colors.black12,
                hoverColor: Colors.black12,
                highlightColor: Colors.black12,
                color: Colors.grey,
                icon: const Icon(Icons.crop_square_rounded, size: 15),
              ),
              IconButton(
                onPressed: () => appWindow.close(),
                splashColor: Colors.transparent,
                splashRadius: 12,
                focusColor: Colors.red[500],
                hoverColor: Colors.red[500],
                highlightColor: Colors.red[500],
                color: Colors.grey,
                icon: const Icon(Icons.close_rounded, size: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
