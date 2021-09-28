import 'package:flutter/material.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/meta/utils/app_theme.dart';

class ActionOptions extends StatelessWidget {
  final List<ActionOptionsObject> actions;

  const ActionOptions({
    Key? key,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return Column(
      children: actions.map((ActionOptionsObject e) {
        return _buttonListTile(
          icon: e.icon,
          color: customTheme.buttonTheme.colorScheme?.primary ??
              AppTheme.darkBackgroundColor,
          onPressed: e.onPressed,
          title: e.title,
          length: actions.length,
          context: context,
          index: actions.indexOf(e),
        );
      }).toList(),
    );
  }
}

class ActionOptionsObject {
  final Widget? icon;
  final String title;
  final VoidCallback? onPressed;

  const ActionOptionsObject(this.title, this.onPressed, {this.icon});
}

Widget _buttonListTile({
  required Widget? icon,
  required String title,
  required VoidCallback? onPressed,
  required Color color,
  required int index,
  required int length,
  required BuildContext context,
}) {
  Radius _curveValue = const Radius.circular(5);
  Radius _curveEmpty = Radius.zero;
  Radius _endExpression = (length == 1 ? _curveValue : _curveEmpty);
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
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: Row(
      children: <Widget>[
        if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: icon,
          ),
        Expanded(
          child: Text(
            title,
            style: TextStyle(color: customTheme.textTheme.bodyText1!.color),
          ),
        ),
        Icon(Icons.arrow_forward_ios_rounded,
            color: customTheme.indicatorColor, size: 15),
      ],
    ),
  );
}
