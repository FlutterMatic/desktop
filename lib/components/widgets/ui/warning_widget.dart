import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manager/components/widgets/ui/round_container.dart';

Widget warningWidget(String text, String asset, Color color,
    [bool showIcon = true]) {
  return Padding(
    padding: const EdgeInsets.only(top: 10),
    child: RoundContainer(
      color: color.withOpacity(0.1),
      borderColor: color,
      radius: 5,
      borderWith: 1.5,
      child: Row(
        children: <Widget>[
          if (showIcon)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SvgPicture.asset(asset, height: 20),
            ),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    ),
  );
}
