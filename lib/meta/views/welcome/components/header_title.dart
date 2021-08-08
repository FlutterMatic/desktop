import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget welcomeHeaderTitle(String iconPath, String title, String description,
    {double iconHeight = 30}) {
  return Column(
    children: <Widget>[
      SvgPicture.asset(iconPath, height: iconHeight),
      const SizedBox(height: 20),
      Text(
        title,
        style: const TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 25),
      Text(
        description,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16),
      ),
    ],
  );
}
