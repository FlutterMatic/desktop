// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/theme.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/meta/utils/general/app_theme.dart';

class ActionOptions extends StatelessWidget {
  final List<ActionOptionsObject> actions;
  // Provides the option to have your own builder for the action buttons
  // or use the default one and must return a Widget
  final Widget? Function(BuildContext context, ActionOptionsObject action)?
      trailingBuilder;

  const ActionOptions({
    Key? key,
    required this.actions,
    this.trailingBuilder,
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
          trailing:
              trailingBuilder != null ? trailingBuilder!(context, e) : null,
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
  required Widget? trailing,
}) {
  Radius curveValue = const Radius.circular(5);
  Radius curveEmpty = Radius.zero;
  Radius endExpression = (length == 1 ? curveValue : curveEmpty);

  return RectangleButton(
    width: double.infinity,
    onPressed: onPressed,
    radius: BorderRadius.only(
      topLeft: index == 0 ? curveValue : endExpression,
      topRight: index == 0 ? curveValue : endExpression,
      bottomLeft: index + 1 == length ? curveValue : endExpression,
      bottomRight: index + 1 == length ? curveValue : endExpression,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: Row(
      children: <Widget>[
        if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: SizedBox(width: 18, child: icon),
          ),
        Expanded(
          child: Text(
            title,
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyText1!.color),
          ),
        ),
        if (trailing != null) trailing,
        Consumer(
          builder: (_, ref, __) {
            ThemeState themeState = ref.watch(themeStateController);

            return Icon(
              Icons.arrow_forward_ios_rounded,
              color: themeState.isDarkTheme ? Colors.white : Colors.black,
              size: 15,
            );
          },
        ),
      ],
    ),
  );
}
