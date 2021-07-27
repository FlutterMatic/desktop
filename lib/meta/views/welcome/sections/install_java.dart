import 'package:flutter/material.dart';
import 'package:manager/meta/views/welcome/components/button.dart';
import 'package:manager/meta/views/welcome/components/header_title.dart';
import 'package:manager/meta/views/welcome/components/progress_indicator.dart';

Widget installJava(
  Function onInstall,
  Function onSkip, {
  required ThemeData theme,
  required bool isInstalling,
  required bool doneInstalling,
  required double completedSize,
  required double totalInstalled,
}) {
  return Column(
    children: [
      welcomeHeaderTitle(
        'assets/images/logos/java.svg',
        'Install Java',
        'Java is sometimes needed in Flutter development. However you can skip if you do not want to install Java.',
      ),
      const SizedBox(height: 50),
      if (!doneInstalling)
        installProgressIndicator(
          disabled: !isInstalling,
          totalInstalled: totalInstalled,
          totalSize: completedSize,
          objectSize: '3.2 GB',
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
                    const Text('Java Installed',
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text(
                        'You have successfully installed Java. Click next to wrap up.',
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
      const SizedBox(height: 20),
      if (!doneInstalling && !isInstalling)
        TextButton(
          onPressed: onSkip as Function(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Skip',
              style: theme.textTheme.bodyText2!.copyWith(fontSize: 12),
            ),
          ),
        ),
    ],
  );
}