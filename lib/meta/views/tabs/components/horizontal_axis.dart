// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';

class HorizontalAxisView extends StatefulWidget {
  final String title;
  final List<Widget> content;
  final bool isVertical;
  final Widget? action;
  final bool canCollapse;

  const HorizontalAxisView({
    Key? key,
    required this.title,
    required this.content,
    this.isVertical = false,
    this.canCollapse = false,
    this.action,
  }) : super(key: key);

  @override
  _HorizontalAxisViewState createState() => _HorizontalAxisViewState();
}

class _HorizontalAxisViewState extends State<HorizontalAxisView> {
  bool _collapsed = false;
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
              child: Text(
                widget.title +
                    (widget.canCollapse && _collapsed ? ' - Collapsed' : ''),
                style: const TextStyle(fontSize: 20),
              ),
            ),
            HSeparators.normal(),
            if (widget.action != null) widget.action!,
            if (widget.canCollapse) ...<Widget>[
              HSeparators.normal(),
              SquareButton(
                size: 30,
                icon: Icon(
                    _collapsed
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18),
                onPressed: () => setState(() => _collapsed = !_collapsed),
              ),
            ]
          ],
        ),
        if (!_collapsed) ...<Widget>[
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
        ] else ...<Widget>[
          VSeparators.small(),
          RoundContainer(
            width: double.infinity,
            // padding: EdgeInsets.zero,
            color: Colors.blueGrey.withOpacity(0.2),
            child: Row(
              children: <Widget>[
                const Icon(Icons.disabled_by_default_rounded),
                HSeparators.small(),
                Text(widget.content.length.toString() +
                    ' item${widget.content.length > 1 ? 's' : ''} hidden'),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
