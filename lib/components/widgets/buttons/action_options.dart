// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/core/notifiers/theme.notifier.dart';
import 'package:fluttermatic/meta/utils/app_theme.dart';

class ActionOptions extends StatelessWidget {
  final List<ActionOptionsObject> actions;

  const ActionOptions({
    Key? key,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: actions.map((ActionOptionsObject e) {
        return _buttonListTile(
          context,
          icon: e.icon,
          color: Theme.of(context).buttonTheme.colorScheme?.primary ??
              AppTheme.darkBackgroundColor,
          onPressed: e.onPressed,
          title: e.title,
          length: actions.length,
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

Widget _buttonListTile(
  BuildContext context, {
  required Widget? icon,
  required String title,
  required VoidCallback? onPressed,
  required Color color,
  required int index,
  required int length,
}) {
  Radius _curveValue = const Radius.circular(5);
  Radius _curveEmpty = Radius.zero;
  Radius _endExpression = (length == 1 ? _curveValue : _curveEmpty);
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
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyText1!.color),
          ),
        ),
        Icon(Icons.arrow_forward_ios_rounded,
            color: context.read<ThemeChangeNotifier>().isDarkTheme
                ? Colors.white
                : Colors.black,
            size: 15),
      ],
    ),
  );
}
