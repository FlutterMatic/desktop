import 'package:flutter/material.dart';
import 'package:manager/components/widgets/buttons/tab_item.dart';

class TabViewWidget extends StatefulWidget {
  final String? defaultPage;
  final List<String> tabNames;
  final List<Widget> tabItems;

  TabViewWidget({
    required this.tabNames,
    required this.tabItems,
    this.defaultPage,
  })  : assert(tabNames.length == tabItems.length,
            'Both item lengths must be the same'),
        assert(tabNames.isNotEmpty && tabItems.isNotEmpty,
            'Item list cannot be empty');

  @override
  _TabViewWidgetState createState() => _TabViewWidgetState();
}

class _TabViewWidgetState extends State<TabViewWidget> {
  int _index = 0;
  final List<Widget> _itemsHeader = <Widget>[];

  @override
  void initState() {
    if (widget.defaultPage != null &&
        widget.tabNames.contains(
            widget.defaultPage!.toLowerCase().substring(0, 1).toUpperCase() +
                widget.defaultPage!.substring(1))) {
      setState(() => _index = widget.tabNames.indexOf(widget.defaultPage!));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _itemsHeader.clear();
    for (int i = 0; i < widget.tabNames.length; i++) {
      _itemsHeader.add(
        tabItemWidget(widget.tabNames[i], () => setState(() => _index = i),
            _index == i, context, i == _index),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _itemsHeader),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 310,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: widget.tabItems[_index],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
