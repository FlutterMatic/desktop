import 'package:flutter/material.dart';

class HoverMessageWithIconAction extends StatefulWidget {
  final Widget icon;
  final String message;
  final Function()? onPressed;

  const HoverMessageWithIconAction({
    Key? key,
    required this.icon,
    required this.message,
    this.onPressed,
  }) : super(key: key);

  @override
  _HoverMessageWithIconActionState createState() =>
      _HoverMessageWithIconActionState();
}

class _HoverMessageWithIconActionState
    extends State<HoverMessageWithIconAction> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    Widget _tile() {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                widget.message,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            if (_isHovering)
              GestureDetector(
                onTap: widget.onPressed,
                child: widget.icon,
              ),
          ],
        ),
      );
    }

    if (widget.onPressed == null) {
      return _tile();
    } else {
      return MaterialButton(
        padding: EdgeInsets.zero,
        onPressed: widget.onPressed,
        hoverColor: Colors.transparent,
        child: _tile(),
      );
    }
  }
}
