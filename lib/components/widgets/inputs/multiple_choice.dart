// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/widgets.dart';

class MultipleChoice extends StatefulWidget {
  final List<String> options;
  final Function(String) onChanged;
  final String? defaultChoiceValue;

  const MultipleChoice({
    Key? key,
    required this.options,
    required this.onChanged,
    this.defaultChoiceValue,
  }) : super(key: key);

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
    List<Widget> _elements = <Widget>[];

    _elements.clear();

    for (int i = 0; i < widget.options.length; i++) {
      _elements.add(
        _circleElement(_value == widget.options[i], widget.options[i],
            (String val) {
          setState(() => _value = val);
          widget.onChanged(val);
        }),
      );
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
        children: <Widget>[
          RectangleButton(
            color: Colors.transparent,
            hoverColor: Colors.transparent,
            width: 15,
            height: 15,
            padding: EdgeInsets.zero,
            radius: BorderRadius.circular(15),
            onPressed: () => onPressed(message),
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
          ),
          HSeparators.small(),
          Expanded(
            child: GestureDetector(
              onTap: () => onPressed(message),
              child: Text(
                message,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
