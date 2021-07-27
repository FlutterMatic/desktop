import 'package:flutter/material.dart';
import 'package:manager/meta/views/welcome/components/button.dart';
import 'package:manager/meta/views/welcome/components/header_title.dart';
import 'package:manager/meta/views/welcome/components/progress_indicator.dart';

Widget installGit(
  Function onInstall, {
  required bool isInstalling,
  required bool doneInstalling,
  required double completedSize,
  required double totalInstalled,
}) {
  return Column(
    children: [
      welcomeHeaderTitle(
        'assets/images/logos/git.svg',
        'Install Git',
        'Flutter relies on Git to get and install dependencies and other tools.',
      ),
      const SizedBox(height: 30),
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
                    const Text('Git Installed', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text(
                        'You have successfully installed Git. Click next to continue.',
                        style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: 30),
      welcomeButton(doneInstalling ? 'Next' : 'Install', onInstall,
          disabled: isInstalling),
    ],
  );
}