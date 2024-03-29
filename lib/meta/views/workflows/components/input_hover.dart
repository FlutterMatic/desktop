// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/widgets/inputs/text_field.dart';

class InputHoverAffect extends StatefulWidget {
  final String hintText;
  final String infoText;
  final int numLines;
  final TextEditingController controller;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String val)? onChanged;

  const InputHoverAffect({
    Key? key,
    required this.hintText,
    required this.infoText,
    this.numLines = 1,
    required this.controller,
    this.inputFormatters,
    this.onChanged,
  }) : super(key: key);

  @override
  _InputHoverAffectState createState() => _InputHoverAffectState();
}

class _InputHoverAffectState extends State<InputHoverAffect> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 400,
            child: CustomTextField(
              autofocus: true,
              hintText: widget.hintText,
              numLines: widget.numLines,
              onChanged: widget.onChanged,
              controller: widget.controller,
              filterFormatters: widget.inputFormatters,
            ),
          ),
          if (_isHovering && MediaQuery.of(context).size.width > 800)
            Expanded(
              child: Row(
                children: <Widget>[
                  HSeparators.normal(),
                  Container(
                    width: 20,
                    height: 2,
                    color: kGreenColor.withOpacity(0.2),
                  ),
                  HSeparators.normal(),
                  Expanded(child: Text(widget.infoText)),
                ],
              ),
            )
        ],
      ),
    );
  }
}
