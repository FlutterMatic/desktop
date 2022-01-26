// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';

class SelectTile extends StatefulWidget {
  final List<String> options;
  final String? defaultValue;
  final Function(String)? onPressed;
  final String? error;
  final bool disable;

  const SelectTile({
    Key? key,
    required this.options,
    this.defaultValue,
    this.onPressed,
    this.disable = false,
    this.error,
  })  : assert(options.length >= 2,
            'List must contain at least 2 or more options.'),
        super(key: key);

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        //Shows options
        Column(
          children: widget.options
              .map(
                (String val) => _selectTile(
                  context,
                  leading: val,
                  onPressed: () {
                    if (widget.disable == false) {
                      widget.onPressed!(val);
                      setState(() => _selected = val);
                    }
                  },
                  selected: val == _selected,
                  disable: widget.disable,
                ),
              )
              .toList(),
        ),
        //Shows error
        if (widget.error != null && widget.error != '')
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(widget.error!),
          ),
      ],
    );
  }
}

Widget _selectTile(
  BuildContext context, {
  required String leading,
  required Function() onPressed,
  required bool selected,
  required bool disable,
}) {
  return RectangleButton(
    color: Colors.transparent,
    width: double.infinity,
    onPressed: disable ? null : onPressed,
    radius: BorderRadius.circular(5),
    height: 50,
    padding: EdgeInsets.zero,
    child: Row(
      children: <Widget>[
        HSeparators.small(),
        Container(
          height: 15,
          width: 15,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            color: selected
                ? Theme.of(context).textTheme.headline1!.color
                : Theme.of(context).hoverColor,
          ),
        ),
        HSeparators.small(),
        Expanded(
          child: Text(leading,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText1!.color)),
        ),
      ],
    ),
  );
}
