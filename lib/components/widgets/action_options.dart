import 'package:flutter/material.dart';
import 'package:flutter_installer/components/widgets/rectangle_button.dart';

class ActionOptions extends StatelessWidget {
  final List<String> buttonTitles;
  final List<Function> buttonOnPressed;

  ActionOptions({
    required this.buttonTitles,
    required this.buttonOnPressed,
  }) : assert(buttonOnPressed.length == buttonTitles.length,
            'Item lengths must be the same');

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return Column(
      children: buttonTitles.map((e) {
        return _buttonListTile(
            buttonOnPressed[buttonTitles.indexOf(e)],
            e,
            customTheme.buttonColor,
            buttonTitles.indexOf(e),
            buttonTitles.length,
            context);
      }).toList(),
    );
  }
}

Widget _buttonListTile(Function onPressed, String title, Color color, int index,
    int length, BuildContext context) {
  Radius _curveValue = Radius.circular(5);
  Radius _curveEmpty = Radius.zero;
  var _endExpression = (length == 1 ? _curveValue : _curveEmpty);
  ThemeData customTheme = Theme.of(context);
  return RectangleButton(
    width: double.infinity,
    onPressed: onPressed,
    radius: BorderRadius.only(
      topLeft: index == 0 ? _curveValue : _endExpression,
      topRight: index == 0 ? _curveValue : _endExpression,
      bottomLeft: index + 1 == length ? _curveValue : _endExpression,
      bottomRight: index + 1 == length ? _curveValue : _endExpression,
    ),
    color: color,
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: Row(
      children: [
        Expanded(
            child: Text(
          title,
          style: TextStyle(color: customTheme.textTheme.bodyText1!.color),
        )),
        Icon(
          Icons.arrow_forward_ios_rounded,
          size: 15,
          color: customTheme.indicatorColor,
        ),
      ],
    ),
  );
}
