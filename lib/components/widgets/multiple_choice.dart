import 'package:flutter/material.dart';
import 'package:flutter_installer/components/widgets/rectangle_button.dart';

class MultipleChoice extends StatefulWidget {
  final List<String> options;
  final Function(String) onChanged;
  final String? defaultChoiceValue;

  MultipleChoice({
    required this.options,
    required this.onChanged,
    this.defaultChoiceValue,
  }) : assert(options.isNotEmpty && options.length >= 2,
            'Options cannot be empty and options needs to be 2 or more.');

  @override
  _MultipleChoiceState createState() => _MultipleChoiceState();
}

String? _value;

class _MultipleChoiceState extends State<MultipleChoice> {
  @override
  void initState() {
    if (widget.defaultChoiceValue != null) {
      setState(() => _value = widget.defaultChoiceValue);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _elements = [];
    _elements.clear();
    for (var i = 0; i < widget.options.length; i++) {
      _elements.add(_circleElement(_value == widget.options[i],
          widget.options[i], (val) => setState(() => _value = val)));
    }
    return Column(children: _elements);
  }

  Widget _circleElement(
      bool selected, String message, Function(String) onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RectangleButton(
            color: Colors.transparent,
            hoverColor: Colors.transparent,
            width: 15,
            height: 15,
            padding: EdgeInsets.zero,
            child: Container(
              height: 15,
              width: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? Colors.blueGrey.withOpacity(0.8)
                    : Colors.transparent,
                border: Border.all(
                    color: Colors.blueGrey.withOpacity(0.5), width: 2),
              ),
            ),
            radius: BorderRadius.circular(15),
            onPressed: () => onPressed(message),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: GestureDetector(
                  onTap: () => onPressed(message),
                  child: Text(message,
                      overflow: TextOverflow.ellipsis, maxLines: 2))),
        ],
      ),
    );
  }
}
