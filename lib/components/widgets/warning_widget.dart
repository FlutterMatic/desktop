import 'package:flutter/material.dart';
import 'package:flutter_installer/components/widgets/round_container.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget warningWidget(String text, String asset, Color color) {
  return Padding(
    padding: const EdgeInsets.only(top: 10),
    child: RoundContainer(
      color: color.withOpacity(0.1),
      borderColor: color,
      radius: 5,
      child: Row(
        children: [
          SvgPicture.asset(asset, height: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    ),
  );
}
