import 'package:flutter/material.dart';
import 'package:manager/meta/views/welcome/components/button.dart';
import 'package:manager/meta/views/welcome/components/header_title.dart';
import 'package:manager/meta/views/welcome/components/progress_indicator.dart';

Widget installFlutter(
  Function onInstall, {
  required bool doneInstalling,
  required bool isInstalling,
  required double completedSize,
  required double totalSize,
}) {
  return Column(
    children: [
      welcomeHeaderTitle(
        'assets/images/logos/flutter.svg',
        'Install Flutter',
        'You will need to install Flutter in your machine to start using Flutter.',
      ),
      const SizedBox(height: 50),
      if (!doneInstalling)
        installProgressIndicator(
          totalInstalled: completedSize,
          totalSize: totalSize,
          objectSize: '1.8 GB',
          disabled: !isInstalling,
        )
      else
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xff363D4D),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_rounded, color: Color(0xff07C2A3)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Flutter Installed',
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text(
                        'Flutter was installed successfully on your machine. Continue to the next step.',
                        style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: 50),
      welcomeButton(doneInstalling ? 'Next' : 'Install', onInstall,
          disabled: isInstalling),
    ],
  );
}