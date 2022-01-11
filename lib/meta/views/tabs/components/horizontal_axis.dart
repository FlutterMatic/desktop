// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/buttons/rectangle_button.dart';
import 'package:manager/meta/utils/app_theme.dart';

class HorizontalAxisView extends StatefulWidget {
  final String title;
  final List<Widget> content;
  final bool isVertical;

  const HorizontalAxisView({
    Key? key,
    required this.title,
    required this.content,
    this.isVertical = false,
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
            // Check if we are at the start of the list. If we are then we
            // don't want to show the left arrow.
            if (_controller.hasClients && _controller.offset > 0)
              RectangleButton(
                width: 30,
                height: 30,
                padding: EdgeInsets.zero,
                onPressed: () {
                  _controller.animateTo(
                    _controller.offset - (265 * 2),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                },
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 12,
                  color: Theme.of(context).isDarkTheme
                      ? Colors.grey
                      : Colors.black,
                ),
              ),
            HSeparators.small(),
            // Check if we are at the end of the list. If we are then we
            // don't want to show the right arrow.
            if (_controller.hasClients &&
                _controller.offset < _controller.position.maxScrollExtent)
              RectangleButton(
                width: 30,
                height: 30,
                padding: EdgeInsets.zero,
                onPressed: () {
                  _controller.animateTo(
                    _controller.offset + (265 * 2),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                },
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: Theme.of(context).isDarkTheme
                      ? Colors.grey
                      : Colors.black,
                ),
              ),
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