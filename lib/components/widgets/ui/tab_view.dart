import 'package:flutter/material.dart';
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
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 310,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: IndexedStack(
                  children:
                      widget.tabs.map((TabViewObject e) => e.widget).toList(),
                  index: _index,
                ),
              ),
            ),
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

Widget tabItemWidget(
    String name, Function() onPressed, bool selected, BuildContext context) {
  ThemeData customTheme = Theme.of(context);
  return RectangleButton(
    width: 130,
    hoverColor: Colors.transparent,
    focusColor: Colors.transparent,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    color: selected ? null : Colors.transparent,
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
