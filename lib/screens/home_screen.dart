import 'package:flutter/material.dart';
import 'package:flutter_installer/utils/constants.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Row(
          children: [
            _installedComponents(),
          ],
        ),
      ),
    );
  }
}

Widget _installedComponents() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const SelectableText(
            'Installed Components',
            style: TextStyle(
                fontSize: 25, color: kDarkColor, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 100),
          RoundButton(
            onPressed: () {},
          ),
        ],
      ),
    ],
  );
}

class RoundButton extends StatelessWidget {
  RoundButton({this.size = 40, required this.onPressed});
  final double size;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: kGreyColor,
      elevation: 0,
      hoverElevation: 0,
      focusElevation: 0,
      highlightElevation: 0,
      minWidth: size,
      height: size,
      child: SizedBox(
        height: size,
        width: size,
        child: const Icon(Icons.settings),
      ),
    );
  }
}
