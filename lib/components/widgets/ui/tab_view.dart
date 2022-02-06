// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';

class TabViewWidget extends StatefulWidget {
  final double? height;
  final String? defaultPage;
  final List<TabViewObject> tabs;

  const TabViewWidget({
    Key? key,
    required this.tabs,
    this.height,
    this.defaultPage,
  }) : super(key: key);

  @override
  _TabViewWidgetState createState() => _TabViewWidgetState();
}

class _TabViewWidgetState extends State<TabViewWidget> {
  int _index = 0;

  @override
  void initState() {
    if (widget.defaultPage != null) {
      setState(() {
        widget.tabs.where((TabViewObject e) {
          if (e.name.toLowerCase() == widget.defaultPage!.toLowerCase()) {
            _index = widget.tabs.indexOf(e);
            return true;
          }
          return false;
        }).toList();
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.tabs.map(
            (TabViewObject e) {
              return _tabItemWidget(
                context,
                name: e.name,
                selected: _index == widget.tabs.indexOf(e),
                onPressed: () =>
                    setState(() => _index = widget.tabs.indexOf(e)),
              );
            },
          ).toList(),
        ),
        HSeparators.small(),
        Expanded(
          child: SizedBox(
            height: widget.height ?? 330,
            child: widget.tabs[_index].widget,
          ),
        ),
      ],
    );
  }
}

class TabViewObject {
  final String name;
  final Widget widget;

  const TabViewObject(this.name, this.widget);
}

Widget _tabItemWidget(
  BuildContext context, {
  required String name,
  required Function() onPressed,
  required bool selected,
}) {
  return RectangleButton(
    width: 130,
    hoverColor: Colors.transparent,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    color: selected
        ? Theme.of(context).colorScheme.secondary.withOpacity(0.2)
        : Colors.transparent,
    padding: const EdgeInsets.all(10),
    onPressed: onPressed,
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        name,
        style: TextStyle(
            color: Theme.of(context)
                .textTheme
                .bodyText1!
                .color!
                .withOpacity(selected ? 1 : .4)),
      ),
    ),
  );
}

class TabViewTabHeadline extends StatelessWidget {
  final String title;
  final List<Widget> content;
  final bool allowContentScroll;
  final TextStyle? titleStyle;

  const TabViewTabHeadline(
      {Key? key,
      required this.title,
      required this.content,
      this.allowContentScroll = true,
      this.titleStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: titleStyle,
        ),
        VSeparators.xSmall(),
        Expanded(
          child: allowContentScroll
              ? SingleChildScrollView(child: _pageContent())
              : _pageContent(),
        ),
      ],
    );
  }

  Widget _pageContent() {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Flex(
        crossAxisAlignment: CrossAxisAlignment.start,
        direction: Axis.vertical,
        children: content,
      ),
    );
  }
}
