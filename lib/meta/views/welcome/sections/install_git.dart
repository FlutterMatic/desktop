import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:provider/provider.dart';
import 'package:manager/meta/views/welcome/components/button.dart';
import 'package:manager/meta/views/welcome/components/header_title.dart';
import 'package:manager/meta/views/welcome/components/progress_indicator.dart';

Widget installGit(
  BuildContext context,
  Function()? onInstall, {
  required bool isInstalling,
  required bool doneInstalling,
}) {
  return Column(
    children: <Widget>[
      welcomeHeaderTitle(
        Assets.git,
        Install.git,
        InstallContent.git,
      ),
      const SizedBox(height: 30),
      if (!doneInstalling)
        installProgressIndicator(
          disabled: !isInstalling,
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
                    const Text(Installed.git, style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text(
                      'You have successfully installed Git. Click next to continue.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: 30),
      WelcomeButton(doneInstalling ? 'Next' : 'Install', onInstall,
          disabled: isInstalling),
    ],
  );
}
