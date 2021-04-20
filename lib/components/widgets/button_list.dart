import 'package:flutter/material.dart';
import 'package:flutter_installer/components/widgets/rectangle_button.dart';
import 'package:flutter_installer/services/themes.dart';

class SelectTile extends StatefulWidget {
  final List<String> options;
  final String? defaultValue;
  final Function(String)? onPressed;
  final String? error;
  final bool disable;

  SelectTile({
    required this.options,
    this.defaultValue,
    this.onPressed,
    this.disable = false,
    this.error,
  }) : assert(options.length >= 2,
            'List must contain at least 2 or more options.');

  @override
  _SelectTileState createState() => _SelectTileState();
}

String? _selected;

class _SelectTileState extends State<SelectTile> {
  @override
  void initState() {
    if (widget.defaultValue != null && mounted) {
      setState(() => _selected = widget.defaultValue);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData customTheme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Shows options
        Column(
          children: widget.options
              .map(
                (val) => _selectTile(val, () {
                  if (widget.disable == false) {
                    widget.onPressed!(val);
                    setState(() => _selected = val);
                  }
                },
                    val == _selected,
                    widget.disable,
                    customTheme.backgroundColor,
                    customTheme.accentColor,
                    context),
              )
              .toList(),
        ),
        //Shows error
        widget.error != null && widget.error != ''
            ? Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(widget.error!),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}

Widget _selectTile(dynamic leading, Function onPressed, bool selected,
    bool disable, Color color, Color hoverColor, BuildContext context) {
  ThemeData customTheme = Theme.of(context);
  return RectangleButton(
    color: Colors.transparent,
    width: double.infinity,
    onPressed: disable ? null : onPressed,
    radius: BorderRadius.circular(5),
    height: 50,
    padding: EdgeInsets.zero,
    child: Row(
      children: [
        const SizedBox(width: 10),
        Container(
          height: 15,
          width: 15,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: currentTheme.currentTheme == ThemeMode.dark
                    ? Colors.white
                    : customTheme.focusColor,
                width: 2),
            color: selected
                ? customTheme.textTheme.headline1!.color
                : customTheme.hoverColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: leading.runtimeType == String
              ? Text(leading,
                  style:
                      TextStyle(color: customTheme.textTheme.bodyText1!.color))
              : leading.runtimeType == Widget
                  ? leading
                  : const Text('Something unexpected is going on...'),
        ),
      ],
    ),
  );
}
