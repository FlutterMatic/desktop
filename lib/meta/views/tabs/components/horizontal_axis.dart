// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';

class HorizontalAxisView extends StatefulWidget {
  final String title;
  final List<Widget> content;
  final bool isVertical;
  final Widget? action;

  const HorizontalAxisView({
    Key? key,
    required this.title,
    required this.content,
    this.isVertical = false,
    this.action,
  }) : super(key: key);

  @override
  _HorizontalAxisViewState createState() => _HorizontalAxisViewState();
}

class _HorizontalAxisViewState extends State<HorizontalAxisView> {
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Text(widget.title, style: const TextStyle(fontSize: 20)),
            ),
            HSeparators.normal(),
            if (widget.action != null) widget.action!,
          ],
        ),
        VSeparators.large(),
        if (widget.isVertical)
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: _size.width > 1800
                ? 5
                : _size.width > 1100
                    ? 4
                    : 3,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 1,
            children: widget.content,
            shrinkWrap: true,
          )
        else
          SingleChildScrollView(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            child: Row(
                children: widget.content.map(
              (Widget e) {
                bool _isFinal =
                    (widget.content.indexOf(e) + 1) == widget.content.length;
                return Padding(
                  padding: EdgeInsets.only(right: _isFinal ? 0 : 15),
                  child: e,
                );
              },
            ).toList()),
          ),
      ],
    );
  }
}
