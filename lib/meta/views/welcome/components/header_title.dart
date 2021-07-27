import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget welcomeHeaderTitle(String iconPath, String title, String description,
    {double iconHeight = 30}) {
  return Column(
    children: [
      SvgPicture.asset(iconPath, height: iconHeight),
      const SizedBox(height: 20),
      Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
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