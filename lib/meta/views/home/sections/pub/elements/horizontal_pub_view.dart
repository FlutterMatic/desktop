import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/widgets/buttons/rectangle_button.dart';
import 'package:manager/core/notifiers/theme.notifier.dart';
import 'package:provider/provider.dart';

class HorizontalAxisView extends StatefulWidget {
  final String title;
  final List<Widget> content;

  const HorizontalAxisView(
      {Key? key, required this.title, required this.content})
      : super(key: key);

  @override
  _HorizontalAxisViewState createState() => _HorizontalAxisViewState();
}

class _HorizontalAxisViewState extends State<HorizontalAxisView> {
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
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
                  color: context.read<ThemeChangeNotifier>().isDarkTheme
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
                  color: context.read<ThemeChangeNotifier>().isDarkTheme
                      ? Colors.grey
                      : Colors.black,
                ),
              ),
            HSeparators.small(),
            RectangleButton(
              height: 30,
              width: 90,
              padding: EdgeInsets.zero,
              child: Text(
                'Show more',
                style: TextStyle(
                  fontSize: 13,
                  color: context.read<ThemeChangeNotifier>().isDarkTheme
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              onPressed: () {},
            ),
          ],
        ),
        VSeparators.large(),
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
