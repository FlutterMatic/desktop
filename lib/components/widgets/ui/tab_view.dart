// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/widgets.dart';

class TabViewWidget extends StatefulWidget {
  final String? defaultPage;
  final List<TabViewObject> tabs;

  const TabViewWidget({
    Key? key,
    required this.tabs,
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
          if (e.name == widget.defaultPage) {
            _index = widget.tabs.indexOf(e);
            return true;
          } else {
            return false;
          }
        });
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
              return tabItemWidget(
                e.name,
                () => setState(() => _index = widget.tabs.indexOf(e)),
                _index == widget.tabs.indexOf(e),
                context,
              );
            },
          ).toList(),
        ),
        HSeparators.small(),
        Expanded(
          child: SizedBox(height: 330, child: widget.tabs[_index].widget),
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

Widget tabItemWidget(
    String name, Function() onPressed, bool selected, BuildContext context) {
  ThemeData customTheme = Theme.of(context);
  return RectangleButton(
    width: 130,
    hoverColor: Colors.transparent,
    focusColor: Colors.transparent,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    color: selected
        ? customTheme.colorScheme.secondary.withOpacity(0.2)
        : Colors.transparent,
    padding: const EdgeInsets.all(10),
    onPressed: onPressed,
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        name,
        style: TextStyle(
            color: customTheme.textTheme.bodyText1!.color!
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
