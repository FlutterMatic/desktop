import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/meta/views/welcome/components/button.dart';
import 'package:provider/provider.dart';
import 'package:manager/meta/views/welcome/components/header_title.dart';
import 'package:manager/meta/views/welcome/components/progress_indicator.dart';

Widget installJava(
  BuildContext context,
  VoidCallback? onInstall,
  VoidCallback? onSkip, {
  required bool isInstalling,
  required bool doneInstalling,
}) {
  return Column(
    children: <Widget>[
      welcomeHeaderTitle(
        Assets.java,
        Install.java,
        InstallContent.java,
      ),
      const SizedBox(height: 50),
      if (!doneInstalling)
        installProgressIndicator(
          disabled: !isInstalling,
          // totalInstalled: totalInstalled,
          // totalSize: completedSize,
          objectSize: '3.2 GB',
        )
      else
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: context.read<ThemeChangeNotifier>().isDarkTheme
                ? const Color(0xff1B2529)
                : const Color(0xffF4F8FA),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.check_rounded, color: Color(0xff40CAFF)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(Installed.java, style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text(InstalledContent.java,
                        style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: 50),
      WelcomeButton(
          doneInstalling ? ButtonTexts.next : ButtonTexts.install, onInstall,
          disabled: isInstalling),
      const SizedBox(height: 20),
      if (!doneInstalling && !isInstalling)
        TextButton(
          onPressed: onSkip,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              ButtonTexts.skip,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
    ],
  );
}
