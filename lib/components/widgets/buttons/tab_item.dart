import 'package:flutter/material.dart';
import 'package:manager/components/widgets/buttons/rectangle_button.dart';

Widget tabItemWidget(String name, Function() onPressed, bool selected,
    BuildContext context, bool current) {
  ThemeData customTheme = Theme.of(context);
  return RectangleButton(
    width: 130,
    hoverColor: Colors.transparent,
    focusColor: Colors.transparent,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    color: selected ? null : Colors.transparent,
    padding: const EdgeInsets.all(10),
    onPressed: onPressed,
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        name,
        style: TextStyle(
            color: customTheme.textTheme.bodyText1!.color!
                .withOpacity(selected ? 1 : .4)),
      ),
    ),
  );
}
