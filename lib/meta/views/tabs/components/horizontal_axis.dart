// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';

class HorizontalAxisView extends StatefulWidget {
  final String title;
  final List<Widget> content;
  final bool isVertical;
  final Widget? action;
  final bool canCollapse;
  final bool isCollapsedInitially;
  final Function(bool isCollapsed)? onCollapse;

  const HorizontalAxisView({
    Key? key,
    required this.title,
    required this.content,
    this.isVertical = false,
    this.canCollapse = false,
    this.isCollapsedInitially = false,
    this.action,
    this.onCollapse,
  }) : super(key: key);

  @override
  _HorizontalAxisViewState createState() => _HorizontalAxisViewState();
}

class _HorizontalAxisViewState extends State<HorizontalAxisView> {
  late bool _collapsed = widget.isCollapsedInitially;
  final ScrollController _controller = ScrollController();

  bool _hoveringOnHiddenTile = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          onDoubleTap: () {
            setState(() => _collapsed = !_collapsed);
            if (widget.onCollapse != null) {
              widget.onCollapse!(_collapsed);
            }
          },
          child: Row(
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
                HSeparators.xSmall(),
                const RoundContainer(
                  width: 2,
                  height: 10,
                  padding: EdgeInsets.zero,
                  child: SizedBox.shrink(),
                ),
                HSeparators.xSmall(),
                SquareButton(
                  tooltip: _collapsed ? 'Expand' : 'Collapse',
                  size: 20,
                  color: Colors.transparent,
                  hoverColor: Colors.transparent,
                  icon: Icon(
                      _collapsed
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18),
                  onPressed: () {
                    setState(() => _collapsed = !_collapsed);
                    if (widget.onCollapse != null) {
                      widget.onCollapse!(_collapsed);
                    }
                  },
                ),
              ]
            ],
          ),
        ),
        if (!_collapsed) ...<Widget>[
          VSeparators.large(),
          if (widget.isVertical)
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: size.width > 1800
                  ? 5
                  : size.width > 1100
                      ? 4
                      : 3,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 1,
              shrinkWrap: true,
              children: widget.content,
            )
          else
            SingleChildScrollView(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              child: Row(
                  children: widget.content.map(
                (Widget e) {
                  bool isFinal =
                      (widget.content.indexOf(e) + 1) == widget.content.length;
                  return Padding(
                    padding: EdgeInsets.only(right: isFinal ? 0 : 15),
                    child: e,
                  );
                },
              ).toList()),
            ),
        ] else ...<Widget>[
          VSeparators.small(),
          MouseRegion(
            onEnter: (_) => setState(() => _hoveringOnHiddenTile = true),
            onExit: (_) => setState(() => _hoveringOnHiddenTile = false),
            child: GestureDetector(
              onDoubleTap: () {
                setState(() => _collapsed = !_collapsed);
                if (widget.onCollapse != null) {
                  widget.onCollapse!(_collapsed);
                }
              },
              child: RoundContainer(
                width: double.infinity,
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.disabled_by_default_rounded),
                    HSeparators.small(),
                    Expanded(
                      child: Text(
                          '${widget.content.length} item${widget.content.length > 1 ? 's' : ''} hidden'),
                    ),
                    HSeparators.normal(),
                    AnimatedOpacity(
                      opacity: _hoveringOnHiddenTile ? 1 : 0,
                      duration: const Duration(milliseconds: 100),
                      child: const Text(
                        'Double click to expand',
                        maxLines: 1,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
