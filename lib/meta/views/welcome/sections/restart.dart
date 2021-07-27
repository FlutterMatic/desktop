
import 'package:flutter/material.dart';
import 'package:manager/meta/views/welcome/components/button.dart';
import 'package:manager/meta/views/welcome/components/header_title.dart';

Widget welcomeRestart(Function onRestart) {
  return Column(
    children: [
      welcomeHeaderTitle(
        'assets/images/icons/confetti.svg',
        'Congrats',
        'All set! You will need to restart your computer to start using Flutter.',
      ),
      const SizedBox(height: 30),
      Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xff363D4D),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Documentation', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            const Text(
                'Read the official Flutter documentation or check our documentation for how to use this app.',
                style: TextStyle(fontSize: 13)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: MaterialButton(
                    height: 50,
                    color: const Color(0xff4C5362),
                    onPressed: () {},
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Flutter Documentation',
                        style: TextStyle(color: Color(0xffCDD4DD))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MaterialButton(
                    height: 50,
                    color: const Color(0xff4C5362),
                    onPressed: () {},
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Our Documentation',
                      style: TextStyle(color: Color(0xffCDD4DD)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 30),
      welcomeButton('Restart', onRestart),
    ],
  );
}
