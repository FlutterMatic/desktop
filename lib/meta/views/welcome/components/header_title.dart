// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';

Widget welcomeHeaderTitle(String iconPath, String title, String description,
    {Color? color, double iconHeight = 30}) {
  return Column(
    children: <Widget>[
      SvgPicture.asset(iconPath, height: iconHeight, color: color),
      VSeparators.large(),
      Text(
        title,
        style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
      ),
      VSeparators.normal(),
      Text(
        description,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16),
      ),
    ],
  );
}
